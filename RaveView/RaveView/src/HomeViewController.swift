import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    // Initialize empty array so it's ready to use
    var sets: [DJSet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup Header
        setupStaticHeader()
        
        // 2. Load Data
        getSets()
        
        // 3. Setup TableView
        tableView.register(UINib(nibName: "SetPreviewTableViewCell", bundle: nil), forCellReuseIdentifier: "SetPreviewCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // formatting
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData() // Refresh table after getting data
    }
    
    func getSets() {
        // Correct Syntax: You must use parameter labels (id:, name:, etc.)
        sets = [
            DJSet(id: 1, name: "Summer Vibes", auth: "DJ Kaled", duration: 60, image: "img1", reviews: []),
            DJSet(id: 2, name: "Techno Bunker", auth: "Adam Beyer", duration: 120, image: "img2", reviews: []),
            DJSet(id: 3, name: "Deep Focus", auth: "Solomun", duration: 45, image: "img3", reviews: [])
        ]
    }
    
    // Handle the segue to pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetails" {
            // Make sure your SetDetailsViewController has a variable: var setInfo: DJSet?
            if let destVC = segue.destination as? SetDetailsViewController {
                if let selectedSet = sender as? DJSet {
                    destVC.setInfo = selectedSet
                }
            }
        }
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
}

// MARK: - UITableViewDataSource & Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count // Fixed: Use 'sets', not 'regularItems'
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetPreviewCell", for: indexPath) as? SetPreviewTableViewCell else {
            return UITableViewCell()
        }
        
        let item = sets[indexPath.row]
        
        // Configure the cell
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        content.secondaryText = item.auth
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sets[indexPath.row]
        
        // Trigger the segue
        performSegue(withIdentifier: "Home_SetDetail", sender: selectedItem)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
