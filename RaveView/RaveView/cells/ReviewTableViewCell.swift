//
//  ReviewTableViewCell.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 9/1/26.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var review: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
