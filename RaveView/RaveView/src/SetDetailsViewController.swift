//
//  SetDetailsViewController.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 9/1/26.
//

import UIKit

class SetDetailsViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var setImg: UIImageView!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var platform: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // 1. Data Models
    var setInfo: DJSet?
    private let api = DJSetsAPI(client: SupabaseManager.shared.client)
    var reviews: [ReviewWithProfile] = [] // This array holds the actual downloaded data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIStyles()
        
        if let data = setInfo {
            populateUI(with: data)
            print("Fetching reviews for Set ID: \(data.id)")
            fetchReviews(query: data.id)
        }
        
        setupTableView()
    }
    
    // MARK: - API Fetching
    func fetchReviews(query: UUID) {
        Task {
            do {
                // Fetch reviews from Supabase
                let results = try await api.fetchReviewsWithProfiles(forSetId: query, limit: 30)
                
                await MainActor.run {
                    self.reviews = results
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
            if hours > 0 {
                duration.text = "\(hours)h \(minutes)m"
            } else {
                duration.text = "\(minutes)m"
            }
        } else {
            duration.text = "--:--"
        }
        
        if let dateObj = data.uploaded_at ?? Optional(data.created_at) {
            date.text = dateObj
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
                    print("Error loading image: \(error)")
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return reviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // SECTION 0: ADD REVIEW CELL
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddReviewCell", for: indexPath) as? AddReviewTableViewCell else {
                return UITableViewCell()
            }
            
            // Connect the delegate so the cell can open the camera
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        // SECTION 1: REVIEW LIST CELLS
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewTableViewCell else {
                return UITableViewCell()
            }
            
            if indexPath.row < reviews.count {
                let reviewData = reviews[indexPath.row]
                // Use the shared 'dateFormatter' property created at top of class
                cell.date.text = dateFormatter.string(from: reviewData.created_at)
                cell.review.text = reviewData.comment
                cell.username.text = reviewData.profiles.display_name ?? reviewData.profiles.username
            }
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    // MARK: - AddReviewTableViewCellDelegate Methods
    // These functions allow the cell to "talk" to this View Controller
    
    func presentFromCell(_ viewController: UIViewController, animated: Bool) {
        // 1. The cell asks us to present the Camera/Gallery alert
        self.present(viewController, animated: animated, completion: nil)
    }
    
    func didPickImage(_ image: UIImage) {
        // 2. The cell sends us the selected image
        print("SetDetailsVC received the image!")
        
        // TODO: Store this image in a variable so you can upload it when the user clicks "Submit"
        // e.g., self.selectedReviewImage = image
    }
    
    func sendReview(rating: Int, comment: String?, wasPresent: Bool) {
        
        guard let currentSet = setInfo else {
                print("Error: No Set Information found (setInfo is nil).")
                return
            }
        
        var review = Review(
            set_id: currentSet.id,
            rating: rating,
            comment: comment,
            was_present: wasPresent
        )
        
        //call api / handle no set error!
    }
}
