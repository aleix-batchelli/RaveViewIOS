//
//  SetDetailsViewController.swift
//  RaveView
//

import UIKit
import Auth
import Supabase

final class SetDetailsViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var setImg: UIImageView!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var platform: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var setId: UUID?
    var setInfo: DJSet?

    private let api = DJSetsAPI(client: SupabaseManager.shared.client)

    var reviews: [ReviewWithProfile] = []
    var selectedReview: ReviewWithProfile?

    // NEW: current user + flag to hide AddReview cell
    private var currentUserId: UUID?
    private var hasMyReview: Bool = false

    private let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private func formattedISODate(_ isoString: String) -> String? {
        let iso1 = ISO8601DateFormatter()
        iso1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso1.date(from: isoString) { return headerDateFormatter.string(from: d) }

        let iso2 = ISO8601DateFormatter()
        if let d = iso2.date(from: isoString) { return headerDateFormatter.string(from: d) }

        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUIStyles()
        setupTableView()

        // NEW: load current user id if logged in
        Task {
            self.currentUserId = try? await SupabaseManager.shared.client.auth.session.user.id
        }

        if let data = setInfo {
            populateUI(with: data)
            fetchReviews(query: data.id)
            return
        }

        if let id = setId {
            Task { await fetchSetAndLoad(id: id) }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SetDetails_ReviewDetails",
           let destinationVC = segue.destination as? ReviewDetailsViewController {
            destinationVC.review = self.selectedReview
        }
    }

    // MARK: - Fetch Set + Reviews
    private func fetchSetAndLoad(id: UUID) async {
        do {
            let set = try await api.fetchSetById(id)

            await MainActor.run {
                self.setInfo = set
                self.populateUI(with: set)
                self.fetchReviews(query: set.id)
            }
        } catch {
            print("Error fetching set by id:", error)
        }
    }

    func fetchReviews(query: UUID) {
        Task {
            do {
                let results = try await api.fetchReviewsWithProfiles(forSetId: query, limit: 30)

                // NEW: determine if current logged user already reviewed this set
                let myId = self.currentUserId
                let iHaveReview = (myId != nil) && results.contains(where: { $0.user_id == myId })

                await MainActor.run {
                    self.reviews = results
                    self.hasMyReview = iHaveReview
                    self.tableView.reloadData()
                }
            } catch {
                print("Search error:", error)
            }
        }
    }

    // MARK: - Populate Header UI
    func populateUI(with data: DJSet) {
        name.text = data.title
        author.text = data.artist_name
        platform.text = data.platform.capitalized
        

        if let seconds = data.duration_sec {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            duration.text = hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
        } else {
            duration.text = "--:--"
        }

        if let u = data.uploaded_at, let s = formattedISODate(u) {
            date.text = s
        } else if let s = formattedISODate(data.created_at) {
            date.text = s
        } else {
            date.text = "Unknown date"
        }

        if let urlString = data.thumbnail_url, let url = URL(string: urlString) {
            Task {
                do {
                    let (imageData, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: imageData) {
                        await MainActor.run {
                            self.setImg.image = image
                            self.setImg.alpha = 0
                            UIView.animate(withDuration: 0.3) {
                                self.setImg.alpha = 1
                            }
                        }
                    }
                } catch {
                    print("Error loading image:", error)
                }
            }
        }
    }

    func setupUIStyles() {
        setImg.layer.cornerRadius = 8
        setImg.clipsToBounds = true
        setImg.contentMode = .scaleAspectFill
    }

    // MARK: - Setup TableView
    func setupTableView() {
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        tableView.register(UINib(nibName: "AddReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "AddReviewCell")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
    }
    @IBAction func playPressed(_ sender: Any) {
        if let url = URL(string: setInfo?.url ?? ""){
            UIApplication.shared.open(url)
        }
    
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - TableView & Cell Delegate
extension SetDetailsViewController: UITableViewDataSource, UITableViewDelegate, AddReviewTableViewCellDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // NEW: show AddReview cell only if user logged in AND user has not reviewed yet
            return (currentUserId != nil && !hasMyReview) ? 1 : 0
        }
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddReviewCell", for: indexPath) as? AddReviewTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewTableViewCell else {
            return UITableViewCell()
        }

        let r = reviews[indexPath.row]
        cell.date.text = reviewDateFormatter.string(from: r.created_at)
        cell.review.text = r.comment
        cell.username.text = r.profiles.display_name ?? r.profiles.username
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            selectedReview = reviews[indexPath.row]
            performSegue(withIdentifier: "SetDetails_ReviewDetails", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - AddReviewTableViewCellDelegate
    func presentFromCell(_ viewController: UIViewController, animated: Bool) {
        present(viewController, animated: animated, completion: nil)
    }

    func didPickImage(_ image: UIImage) {
        print("SetDetailsVC received the image!")
    }

    func sendReview(rating: Int, comment: String?, wasPresent: Bool, image: UIImage?) {
        guard let currentSet = setInfo else { return }
        guard currentUserId != nil else { return }

        // NEW: extra safety (even if cell hidden)
        if hasMyReview { return }

        Task {
            do {
                try await api.createReview(
                    setId: currentSet.id,
                    rating: rating,
                    comment: comment,
                    wasPresent: wasPresent,
                    image: image
                )
                fetchReviews(query: currentSet.id)
            } catch {
                print("Error uploading review:", error)
            }
        }
    }
}

private let reviewDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .none
    return df
}()
