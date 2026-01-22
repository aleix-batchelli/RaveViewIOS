// HomeViewController.swift

import UIKit
import Foundation
import Supabase

// MARK: - Model (matches table dj_sets)
struct DJSetRow: Codable, Identifiable {
    let id: UUID
    let title: String
    let artist_name: String
    let url: String
    let platform: String
    let duration_sec: Int?
    let uploaded_at: String?      
    let thumbnail_url: String?
    let created_by: UUID
    let created_at: Date
    let avg_rating: Double?
    let ratings_count: Int?
}



// MARK: - API
struct DJSetsAPI {
    let client: SupabaseClient

    func fetchTopByReviews(limit: Int = 10) async throws -> [DJSetRow] {
        try await client
            .from("dj_sets")
            .select()
            .order("ratings_count", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func searchSets(query: String, limit: Int = 30) async throws -> [DJSetRow] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }

        let pattern = "*\(q)*"

        return try await client
            .from("dj_sets")
            .select()
            .or("title.ilike.\(pattern),artist_name.ilike.\(pattern)")
            .limit(limit)
            .execute()
            .value
    }
}

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!

    private let api = DJSetsAPI(client: SupabaseManager.shared.client)
    var sets: [DJSetRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStaticHeader()

        tableView.register(UINib(nibName: "SetPreviewTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "SetPreviewCell")

        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        getSets()
    }

    // Fetch top 10 sets by number of reviews (ratings_count)
    func getSets() {
        Task {
            do {
                let result = try await api.fetchTopByReviews(limit: 10)
                await MainActor.run {
                    self.sets = result
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching sets:", error)
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetails" {
            if let destVC = segue.destination as? SetDetailsViewController,
               let selectedSet = sender as? DJSetRow {
                // Adjust SetDetailsViewController to accept DJSetRow or map it
                // destVC.setInfo = selectedSet
            }
        }
    }

    func setupStaticHeader() {
        guard let customHeader = Bundle.main.loadNibNamed("TopBarTableViewCell", owner: self, options: nil)?.first as? TopBarTableViewCell else {
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
}

// MARK: - UITableViewDataSource & Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetPreviewCell", for: indexPath) as? SetPreviewTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: sets[indexPath.row])
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sets[indexPath.row]

        // If your segue id is "Home_SetDetail", keep that
        performSegue(withIdentifier: "Home_SetDetail", sender: selectedItem)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}



