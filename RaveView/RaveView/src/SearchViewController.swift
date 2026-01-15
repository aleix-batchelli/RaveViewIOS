//
//  SearchViewController.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 8/1/26.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // The container for your top bar
    @IBOutlet weak var headerView: UIView!
    
    // The search input field
    @IBOutlet weak var searchBar: UITextField!
    
    // Data Source: Empty by default, populated when searching
    var searchResults: [DJSet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Setup Header
        setupStaticHeader()
        
        // 2. Setup Search Bar
        searchBar.delegate = self
        searchBar.placeholder = "Search for sets..."
        
        // 3. Setup TableView (Using the Custom XIB)
        // CHANGED: Register the NIB instead of the generic class
        tableView.register(UINib(nibName: "SetPreviewTableViewCell", bundle: nil), forCellReuseIdentifier: "SetPreviewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Hide empty rows
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Search Logic
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let query = textField.text, !query.isEmpty {
            fetchSearchResults(query: query)
        }
        return true
    }
    
    func fetchSearchResults(query: String) {
        print("Fetching results for: \(query)")
        
        // FAKE RESULTS
        searchResults = [
            DJSet(id: 101, name: "Search Result: \(query)", auth: "Test Artist 1", duration: 60, image: "img_a", reviews: []),
            DJSet(id: 102, name: "Best of \(query)", auth: "Test Artist 2", duration: 90, image: "img_b", reviews: []),
            DJSet(id: 103, name: "Underground \(query)", auth: "Test Artist 3", duration: 120, image: "img_c", reviews: [])
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Header Setup
    
    func setupStaticHeader() {
        // Ensure we cast to the specific class if possible, or just UIView
        guard let customHeader = Bundle.main.loadNibNamed("TopBarTableViewCell", owner: self, options: nil)?.first as? UIView else {
            print("Error: Could not load TopBarTableViewCell from XIB")
            return
        }
        
        headerView.addSubview(customHeader)
        
        // Use Constraints for safety (matches HomeViewController logic)
        customHeader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customHeader.topAnchor.constraint(equalTo: headerView.topAnchor),
            customHeader.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            customHeader.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            customHeader.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Search_SetDetail" {
            if let destVC = segue.destination as? SetDetailsViewController {
                if let selectedSet = sender as? DJSet {
                    destVC.setInfo = selectedSet
                }
            }
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // CHANGED: Dequeue with the specific class casting
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetPreviewCell", for: indexPath) as? SetPreviewTableViewCell else {
            return UITableViewCell()
        }
        
        let item = searchResults[indexPath.row]
        
        // CHANGED: Access IBOutlets directly (No 'defaultContentConfiguration')
        //cell.titleLabel?.text = item.name
        //cell.artistLabel?.text = item.auth
        //cell.coverImageView?.image = UIImage(named: item.image)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = searchResults[indexPath.row]
        
        performSegue(withIdentifier: "Search_SetDetail", sender: selectedItem)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
