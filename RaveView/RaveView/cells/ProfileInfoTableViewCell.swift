//
//  ProfileInfoTableViewCell.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 8/1/26.
//

import UIKit

class ProfileInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var numReviews: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var UserNameId: UILabel!
    @IBOutlet weak var UserNameVisible: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Opcional: avatar redondo
        profileImg.layer.cornerRadius = profileImg.bounds.height / 2
        profileImg.clipsToBounds = true
    }

    func configure(profile: Profile, reviewsCount: Int) {
        UserNameId.text = "@\(profile.username)"
        UserNameVisible.text = profile.display_name ?? profile.username
        numReviews.text = "\(reviewsCount)"

        // Avatar
        if let urlString = profile.avatar_url,
           let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImg.image = UIImage(named: "avatar_placeholder") // pon una imagen en Assets si quieres
        }
    }

    private func loadImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run {
                    self.profileImg.image = UIImage(data: data)
                }
            } catch {
                print("AVATAR LOAD ERROR:", error)
            }
        }
    }
}

