import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // This is the static container view you placed above the TableView in Storyboard
    @IBOutlet weak var headerView: UIView!
    
    // Cleaned up data: This array now ONLY holds the actual list items
    let regularItems = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup the Static Header
        // We load the "TopBarTableViewCell" XIB into the headerView container
        setupStaticHeader()
        
        // 2. Setup the TableView
        // We ONLY register the list item cell now. The header is handled above.
        tableView.register(UINib(nibName: "SetPreviewTableViewCell", bundle: nil), forCellReuseIdentifier: "SetPreviewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    func setupStaticHeader() {
        // Load the XIB and cast it to your specific 'TopBarTableViewCell' class
        // This allows you to use the cell design as a standard view
        guard let customHeader = Bundle.main.loadNibNamed("TopBarTableViewCell", owner: self, options: nil)?.first as? TopBarTableViewCell else {
            print("Error: Could not load TopBarTableViewCell from XIB")
            return
        }
        
        // Add it to the container view
        headerView.addSubview(customHeader)
        
        // Add constraints to make the cell fill the container exactly
        customHeader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customHeader.topAnchor.constraint(equalTo: headerView.topAnchor),
            customHeader.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            customHeader.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            customHeader.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])
        
        // Optional: Configure data on your static header here
        // customHeader.myLabel.text = "Profile Name"
    }
}

// MARK: - UITableViewDataSource & Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    // STEP 1: Only 1 section is needed now (for the list)
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // STEP 2: Return the count of your items
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regularItems.count
    }
    
    // STEP 3: Configure only the list cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // We no longer need to check for Section 0 here
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetPreviewCell", for: indexPath) as? SetPreviewTableViewCell else {
            return UITableViewCell()
        }
        
        
        return cell
    }
    
    // STEP 4: Handle clicks
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // No need to check sections, everything in the table is clickable
        print("Tapped on: \(regularItems[indexPath.row])")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
