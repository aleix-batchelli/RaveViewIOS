// SearchViewController.swift

import UIKit

final class SearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var searchBar: UITextField!

    private let api = DJSetsAPI(client: SupabaseManager.shared.client)

    var searchResults: [DJSet] = []
    private var selectedSet: DJSet?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStaticHeader()

        searchBar.delegate = self
        searchBar.placeholder = "Search for sets..."
        searchBar.returnKeyType = .search
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.textColor = UIColor.white
        searchBar.attributedPlaceholder = NSAttributedString(
            string: "Search...",
            attributes: [.foregroundColor: UIColor.white]
        )

        let imageAux = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageAux.tintColor = .white
        imageAux.contentMode = .scaleAspectFit

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        imageAux.frame = CGRect(x: 6, y: 0, width: 18, height: 20)
        container.addSubview(imageAux)

        searchBar.leftView = container
        searchBar.leftViewMode = .always

        tableView.register(UINib(nibName: "SetPreviewTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "SetPreviewCell")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    // MARK: - Search Logic
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        fetchSearchResults(query: textField.text ?? "")
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
           let destinationVC = segue.destination as? SetDetailsViewController {

            // 2 opciones: o pasar el set entero, o pasar solo el id
            if let set = sender as? DJSet {
                destinationVC.setInfo = set          // ya tienes todo el set
                destinationVC.setId = set.id         // opcional, por si lo usas
            } else if let id = sender as? UUID {
                destinationVC.setId = id             // si algún día pasas solo el id
            }
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

        // Esto dispara prepare(for:sender:) y abre SetDetailsViewController
        performSegue(withIdentifier: "Search_SetDetail", sender: selectedItem)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
