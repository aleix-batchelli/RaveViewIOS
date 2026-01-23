//
//  ProfileViewController.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 8/1/26.
//

import UIKit

final class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!

    private let djSetsAPI = DJSetsAPI(client: SupabaseManager.shared.client)

    private var headerCell: ProfileInfoTableViewCell?
    var reviews: [Review] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStaticHeader()

        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        Task { await loadProfileAndReviews() }
    }

    private func loadProfileAndReviews() async {
        do {
            let profile = try await djSetsAPI.fetchMyProfile()

            let myReviews = try await djSetsAPI.fetchMyReviews(limit: 30)

            await MainActor.run {
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
        guard let loaded = Bundle.main.loadNibNamed("ProfileInfoTableViewCell", owner: self, options: nil)?.first as? ProfileInfoTableViewCell else {
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
}

// MARK: - UITableViewDataSource & Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewTableViewCell else {
            return UITableViewCell()
        }

        let review = reviews[indexPath.row]


        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

