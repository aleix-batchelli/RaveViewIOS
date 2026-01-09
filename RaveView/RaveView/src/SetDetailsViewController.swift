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
    
    var setInfo: DJSet? // Add this variable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the static header (Top Bar)
        setupStaticHeader()
        
        if let data = setInfo {
            print("Received: \(data.name)")
            // nameLabel.text = data.name
        }
        
        // 2. Setup the TableView for Reviews
        setupTableView()
        
        
    }
    
    func setupTableView() {
        // Register the XIB for the Review Cell
        // MAKE SURE: Your XIB filename is "ReviewTableViewCell"
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // formatting
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        // Remove extra empty lines at the bottom
        tableView.tableFooterView = UIView()
    }
    
    func setupStaticHeader() {
        guard let customHeader = Bundle.main.loadNibNamed("TopBarTableViewCell", owner: self, options: nil)?.first as? TopBarTableViewCell else {
            print("Error: Could not load TopBarTableViewCell from XIB")
            return
        }
        
        // FIX: Use 'headerView' here (not headerVIew)
        headerView.addSubview(customHeader)
        
        customHeader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // FIX: Ensure all constraints use 'headerView'
            customHeader.topAnchor.constraint(equalTo: headerView.topAnchor),
            customHeader.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            customHeader.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            customHeader.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])
    }
    
    // Put this inside SetDetailsViewController
    @IBAction func backButtonTapped(_ sender: UIButton) {
        // 1. Check if we are in a Navigation Controller (Push Segue)
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            // 2. Otherwise, we are a Modal/Sheet (Present Segue)
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - TableView Configuration
extension SetDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setInfo?.reviews.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the ReviewCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewTableViewCell else {
            // Fallback if casting fails (prevents crash)
            return UITableViewCell()
        }
        
        // Configure the cell (Assuming your ReviewCell has a label)
        // cell.commentLabel.text = reviews[indexPath.row]
        
        // Optional: Make it non-clickable if it's just a review
        cell.selectionStyle = .none
        
        return cell
    }
}
