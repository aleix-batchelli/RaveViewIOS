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

        // 1. Setup Header (Safe Method)
        setupStaticHeader()
        
        // 2. Setup Search Bar
        searchBar.delegate = self // Handle "Enter" key
        searchBar.placeholder = "Search for sets..."
        
        // 3. Setup TableView
        // Note: You can also register "SetPreviewTableViewCell" here if you want the nicer design
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RegularCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Hide empty rows when there are no results
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Search Logic
    
    // This function runs when the user presses "Return" on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hide keyboard
        
        if let query = textField.text, !query.isEmpty {
            fetchSearchResults(query: query)
        }
        return true
    }
    
    func fetchSearchResults(query: String) {
        // TODO: Implement actual API call here using 'query'
        print("Fetching results for: \(query)")
        
        // FAKE RESULTS: Create dummy data based on the search
        searchResults = [
            DJSet(id: 101, name: "Search Result: \(query)", auth: "Test Artist 1", duration: 60, image: "img_a", reviews: []),
            DJSet(id: 102, name: "Best of \(query)", auth: "Test Artist 2", duration: 90, image: "img_b", reviews: []),
            DJSet(id: 103, name: "Underground \(query)", auth: "Test Artist 3", duration: 120, image: "img_c", reviews: [])
        ]
        
        // Refresh the UI
        tableView.reloadData()
    }
    
    // MARK: - Header Setup
    
    func setupStaticHeader() {
        // Load the XIB
        guard let customHeader = Bundle.main.loadNibNamed("TopBarTableViewCell", owner: self, options: nil)?.first as? UIView else {
            print("Error: Could not load TopBarTableViewCell from XIB")
            return
        }
        
        // Add to view
        headerView.addSubview(customHeader)
        
        // FIX: Use Frame + AutoresizingMask to prevent crashes with UITableViewCell
        customHeader.frame = headerView.bounds
        customHeader.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegularCell", for: indexPath)
        
        let item = searchResults[indexPath.row]
        
        // Configure standard cell
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        content.secondaryText = item.auth
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = searchResults[indexPath.row]
        
        // Perform Segue
        performSegue(withIdentifier: "Search_SetDetail", sender: selectedItem)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
