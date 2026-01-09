//
//  ProfileViewController.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 8/1/26.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // Ensure this is connected to the View above your TableView in Storyboard
    @IBOutlet weak var headerView: UIView!
    
    // Changed: Array now holds 'Review' structs instead of Strings
    var reviews: [Review] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Setup the Static Header
        setupStaticHeader()
        
        // 2. Load API Data (Mock)
        getReviews()
        
        // 3. Setup the TableView for regular items only
        // Note: You might want to switch this to a custom cell (e.g. "ReviewCell") later
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RegularCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Optional: Remove extra separators below the content
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - API Calls
    
    func getReviews() {
        // TODO: Implement actual API call here
        // For now, populate with dummy data
        reviews = [
            Review(id: "r1", title: "Amazing night!", body: "Loved the transitions.", author: "User1", rating: 5),
            Review(id: "r2", title: "Solid set", body: "Good energy throughout.", author: "User2", rating: 4),
            Review(id: "r3", title: "Too crowded", body: "Music was great though.", author: "User3", rating: 3)
        ]
        
        tableView.reloadData()
    }
    
    func fetchDJSet(for reviewID: String) -> DJSet {
        // TODO: Implement API logic to find which DJ Set this review belongs to.
        // For now, return a placeholder/dummy DJSet.
        return DJSet(id: 999, name: "Fetched Set Example", auth: "Fetched Artist", duration: 120, image: "placeholder_img", reviews: [])
    }
    
    // MARK: - Header Setup
    
    func setupStaticHeader() {
        // Using "Frame" method to avoid constraints crashes with Cells in Views
        // Ensure the XIB filename is exactly "ProfileInfoTableViewCell"
        guard let profileHeader = Bundle.main.loadNibNamed("ProfileInfoTableViewCell", owner: self, options: nil)?.first as? UIView else {
            print("Error: Could not load ProfileInfoTableViewCell from XIB")
            return
        }
        
        headerView.addSubview(profileHeader)
        
        // Set frame and autoresizing mask (Safe for Cells)
        profileHeader.frame = headerView.bounds
        profileHeader.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profle_SetDetail" {
            if let destVC = segue.destination as? SetDetailsViewController {
                if let selectedSet = sender as? DJSet {
                    destVC.setInfo = selectedSet
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegularCell", for: indexPath)
        
        let review = reviews[indexPath.row]
        
        // Configure standard cell with Review data
        var content = cell.defaultContentConfiguration()
        content.text = review.title
        content.secondaryText = "\(review.rating)/5 - \(review.author)"
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedReview = reviews[indexPath.row]
        
        // 1. Fetch the Set associated with this review (Mock function)
        let setToSend = fetchDJSet(for: selectedReview.id)
        
        // 2. Perform Segue sending the DJSet
        performSegue(withIdentifier: "Profile_SetDetail", sender: setToSend)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
