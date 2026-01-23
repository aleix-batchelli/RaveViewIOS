//
//  ProfileViewController.swift
//  RaveView
//

import UIKit

protocol ProfileInfoTableViewCellDelegate: AnyObject {
    func didTapLogout()
}

final class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!

    private let djSetsAPI = DJSetsAPI(client: SupabaseManager.shared.client)

    private var headerCell: ProfileInfoTableViewCell?
    private var myProfile: Profile?
    private var reviews: [Review] = []

    private var selectedSetId: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStaticHeader()

        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "ReviewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        headerCell?.delegate = self

        Task { await loadProfileAndReviews() }
    }

    private func loadProfileAndReviews() async {
        do {
            let profile = try await djSetsAPI.fetchMyProfile()
            let myReviews = try await djSetsAPI.fetchMyReviews(limit: 30)

            await MainActor.run {
                self.myProfile = profile
                self.reviews = myReviews
                self.headerCell?.configure(profile: profile, reviewsCount: myReviews.count)
                self.tableView.reloadData()
            }
        } catch {
            print("PROFILE SCREEN ERROR:", error)
        }
    }

    // MARK: - Header Setup

    private func setupStaticHeader() {
        guard let loaded = Bundle.main
            .loadNibNamed("ProfileInfoTableViewCell", owner: self, options: nil)?
            .first as? ProfileInfoTableViewCell else {
            print("Error: Could not load ProfileInfoTableViewCell from XIB")
            return
        }

        headerCell = loaded
        headerView.addSubview(loaded)

        loaded.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loaded.topAnchor.constraint(equalTo: headerView.topAnchor),
            loaded.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            loaded.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            loaded.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile_SetDetail" {
            guard let setId = selectedSetId else { return }

            // Destination may be direct VC or embedded in UINavigationController
            if let vc = segue.destination as? SetDetailsViewController {
                vc.setId = setId
            } else if let nav = segue.destination as? UINavigationController,
                      let vc = nav.topViewController as? SetDetailsViewController {
                vc.setId = setId
            }
        }
    }
    
}

// MARK: - UITableViewDataSource & Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell",
                                                       for: indexPath) as? ReviewTableViewCell else {
            return UITableViewCell()
        }

        let r = reviews[indexPath.row]
        cell.review.text = r.comment
        cell.username.text = myProfile?.username ?? "—"
        cell.date.text = dateFormatter.string(from: r.created_at)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let r = reviews[indexPath.row]
        selectedSetId = r.set_id

        performSegue(withIdentifier: "Profile_SetDetail", sender: self)
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .none
    return df
}()

extension ProfileViewController: ProfileInfoTableViewCellDelegate {
    
    
    func didTapLogout() {

        djSetsAPI.logout()
        
        let loginVC = storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
        view.window?.rootViewController = loginVC
        view.window?.makeKeyAndVisible( )
    
    }
}


