import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    var sets: [DJSet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStaticHeader()
        getSets()
        
        // 1. Keep this registration since you are using a XIB file
        tableView.register(UINib(nibName: "SetPreviewTableViewCell", bundle: nil), forCellReuseIdentifier: "SetPreviewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Automatic height calculation
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData()
    }
    
    func getSets() {
        sets = [
            DJSet(id: 1, name: "Summer Vibes", auth: "DJ Kaled", duration: 60, image: "img1", reviews: []),
            DJSet(id: 2, name: "Techno Bunker", auth: "Adam Beyer", duration: 120, image: "img2", reviews: []),
            DJSet(id: 3, name: "Deep Focus", auth: "Solomun", duration: 45, image: "img3", reviews: [])
        ]
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // MATCHED Identifier
        if segue.identifier == "ShowDetails" {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetPreviewCell", for: indexPath) as? SetPreviewTableViewCell else {
            return UITableViewCell()
        }
        
        let item = sets[indexPath.row]
        
        // --- FIX STARTS HERE ---
        // Do NOT use defaultContentConfiguration().
        // Access the custom outlets directly.
        // Make sure these names match the variables in your SetPreviewTableViewCell.swift file.
        
        //cell.titleLabel?.text = item.name      // Replace 'titleLabel' with your actual outlet name
        //cell.artistLabel?.text = item.auth     // Replace 'artistLabel' with your actual outlet name
        //cell.coverImageView?.image = UIImage(named: item.image)
        // --- FIX ENDS HERE ---
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sets[indexPath.row]
        
        // MATCHED Identifier: "ShowDetails"
        performSegue(withIdentifier: "ShowDetails", sender: selectedItem)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
