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
    
    // Array holds 'Review' structs
    var reviews: [Review] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Setup the Static Header
        setupStaticHeader()
        
        // 2. Load API Data (Mock)
        getReviews()
        
        // 3. Setup TableView with Custom XIB
        // CHANGED: Register the NIB for "ReviewCell"
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Remove extra separators
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData()
    }
    
    // MARK: - API Calls
    
    func getReviews() {
        // Mock Data
        reviews = [
            Review(id: "r1", title: "Amazing night!", body: "Loved the transitions.", author: "User1", rating: 5),
            Review(id: "r2", title: "Solid set", body: "Good energy throughout.", author: "User2", rating: 4),
            Review(id: "r3", title: "Too crowded", body: "Music was great though.", author: "User3", rating: 3)
        ]
        
        tableView.reloadData()
    }
    
    func fetchDJSet(for reviewID: String) -> DJSet {
        return DJSet(id: 999, name: "Fetched Set Example", auth: "Fetched Artist", duration: 120, image: "placeholder_img", reviews: [])
    }
    
    // MARK: - Header Setup
    
    func setupStaticHeader() {
        guard let profileHeader = Bundle.main.loadNibNamed("ProfileInfoTableViewCell", owner: self, options: nil)?.first as? UIView else {
            print("Error: Could not load ProfileInfoTableViewCell from XIB")
            return
        }
        
        headerView.addSubview(profileHeader)
        
        // SWITCHED TO CONSTRAINTS (Safer than Frame)
        profileHeader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileHeader.topAnchor.constraint(equalTo: headerView.topAnchor),
            profileHeader.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            profileHeader.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            profileHeader.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // FIXED TYPO: "Profle" -> "Profile" to match didSelectRowAt
        if segue.identifier == "Profile_SetDetail" {
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
        // CHANGED: Dequeue the custom class
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewTableViewCell else {
            return UITableViewCell()
        }
        
        let review = reviews[indexPath.row]
        
        // CHANGED: Assign data directly to IBOutlets
        // Make sure these outlets exist in your ReviewTableViewCell.swift
        //cell.titleLabel?.text = review.title
        //cell.bodyLabel?.text = review.body
        //cell.authorLabel?.text = review.author
        //cell.ratingLabel?.text = "\(review.rating)/5"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedReview = reviews[indexPath.row]
        let setToSend = fetchDJSet(for: selectedReview.id)
        
        // Identifier: "Profile_SetDetail"
        performSegue(withIdentifier: "Profile_SetDetail", sender: setToSend)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
