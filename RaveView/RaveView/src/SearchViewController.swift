//
//  SearchViewController.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 8/1/26.
//

import UIKit

final class SearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var searchBar: UITextField!

    private let api = DJSetsAPI(client: SupabaseManager.shared.client)

    // ✅ Now using the Supabase model
    var searchResults: [DJSetRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStaticHeader()

        searchBar.delegate = self
        searchBar.placeholder = "Search for sets..."
        searchBar.returnKeyType = .search

        tableView.register(UINib(nibName: "SetPreviewTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "SetPreviewCell")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    // MARK: - Search Logic

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        let query = textField.text ?? ""
        fetchSearchResults(query: query)

        return true
    }

    func fetchSearchResults(query: String) {
        Task {
            do {
                let results = try await api.searchSets(query: query, limit: 30)
                await MainActor.run {
                    self.searchResults = results
                    self.tableView.reloadData()
                }
            } catch {
                print("Search error:", error)
            }
        }
    }

    // MARK: - Header Setup

    func setupStaticHeader() {
        guard let customHeader = Bundle.main.loadNibNamed("TopBarTableViewCell", owner: self, options: nil)?.first as? UIView else {
            print("Error: Could not load TopBarTableViewCell from XIB")
            return
        }

        headerView.addSubview(customHeader)
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
        if segue.identifier == "Search_SetDetail",
           let destVC = segue.destination as? SetDetailsViewController,
           let selectedSet = sender as? DJSetRow {

            // ⚠️ You must update SetDetailsViewController to accept DJSetRow
            // destVC.setInfoRow = selectedSet
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetPreviewCell", for: indexPath) as? SetPreviewTableViewCell else {
            return UITableViewCell()
        }

        let item = searchResults[indexPath.row]
        cell.configure(with: item)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = searchResults[indexPath.row]
        performSegue(withIdentifier: "Search_SetDetail", sender: selectedItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

