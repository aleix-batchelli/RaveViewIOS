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
        
        // Initial UI Setup
        setupUIStyles()
        
        // 2. Populate Header Info & Fetch Reviews
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
                    self.tableView.reloadData() // Reload table to show new data
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
        
        // Format Duration
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
        
        // Format Date
        if let dateObj = data.uploaded_at ?? Optional(data.created_at) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            date.text = dateObj
        } else {
            date.text = "Unknown date"
        }
        
        // Load Image (Async)
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
        // Register Review Cell
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        
        // Register Add Review Cell
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

// MARK: - TableView Configuration
extension SetDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 1. Define Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        // Always 2 sections: Section 0 (Add Review), Section 1 (Review List)
        return 2
    }
    
    // 2. Define Rows per Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // Section One: Always 1 cell (The "Add Review" button)
            return 1
        } else {
            // Section Two: The number of downloaded reviews
            // ERROR FIX: Do not use setInfo?.ratings_count here, or it will crash if data hasn't loaded yet.
            return reviews.count
        }
    }
    
    // 3. Configure Cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // SECTION 0: ADD REVIEW CELL
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddReviewCell", for: indexPath) as? AddReviewTableViewCell else {
                return UITableViewCell()
            }
            
            cell.selectionStyle = .none
            return cell
            
        // SECTION 1: REVIEW LIST CELLS
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewTableViewCell else {
                return UITableViewCell()
            }
            
            // ERROR FIX: Populate cell with actual data
            // We verify the index is safe before accessing the array
            if indexPath.row < reviews.count {
                let reviewData = reviews[indexPath.row]
                
                // Call the configure method on the cell (ensure you added this to ReviewTableViewCell)
                cell.date.text = DateFormatter().string(from: reviewData.created_at)
                cell.review.text = reviewData.comment
                cell.username.text = reviewData.profiles.display_name ?? reviewData.profiles.username
            }
            
            cell.selectionStyle = .none
            return cell
        }
    }
}
