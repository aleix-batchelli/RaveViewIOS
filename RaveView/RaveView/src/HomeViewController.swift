import UIKit
import Foundation
import Supabase

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

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!

    private let api = DJSetsAPI(client: SupabaseManager.shared.client)
    var sets: [DJSet] = []

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Home_SetDetail" {
            
            if let destVC = segue.destination as? SetDetailsViewController,
               let selectedSet = sender as? DJSet {
                
                destVC.setInfo = selectedSet
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

        
        performSegue(withIdentifier: "Home_SetDetail", sender: selectedItem)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}



