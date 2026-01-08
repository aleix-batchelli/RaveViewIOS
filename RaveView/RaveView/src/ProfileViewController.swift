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
    
    // Cleaned items: Removed "Top Bar Header" from the array
    let items = ["Item 1", "Item 2", "Item 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Setup the Static Header
        setupStaticHeader()
        
        // 2. Setup the TableView for regular items only
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RegularCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Optional: Remove extra separators below the content
        tableView.tableFooterView = UIView()
    }
    
    func setupStaticHeader() {
        // Load the XIB and cast it to 'ProfileInfoTableViewCell'
        // Ensure the XIB filename is exactly "ProfileInfoTableViewCell"
        guard let profileHeader = Bundle.main.loadNibNamed("ProfileInfoTableViewCell", owner: self, options: nil)?.first as? ProfileInfoTableViewCell else {
            print("Error: Could not load ProfileInfoTableViewCell from XIB")
            return
        }
        
        // Add it to the container view
        headerView.addSubview(profileHeader)
        
        // Pin it to the edges
        profileHeader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileHeader.topAnchor.constraint(equalTo: headerView.topAnchor),
            profileHeader.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            profileHeader.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            profileHeader.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegularCell", for: indexPath)
        
        // Configure standard cell
        var content = cell.defaultContentConfiguration()
        content.text = items[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped on: \(items[indexPath.row])")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Removed heightForRowAt so the table uses standard heights automatically.
    // If you need specific heights for the list items, add it back, but do NOT include the check for row 0.
}
