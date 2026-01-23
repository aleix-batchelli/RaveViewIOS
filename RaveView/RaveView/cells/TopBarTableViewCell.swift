//
//  TopBarTableViewCell.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 8/1/26.
//

import UIKit

final class TopBarTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImg: UIImageView!

    private let api = DJSetsAPI(client: SupabaseManager.shared.client)

    override func awakeFromNib() {
        super.awakeFromNib()

        userProfileImg.layer.cornerRadius = userProfileImg.bounds.width / 2
        userProfileImg.clipsToBounds = true
        userProfileImg.contentMode = .scaleAspectFill
        userProfileImg.image = UIImage(systemName: "person.crop.circle")

        loadMyAvatar()
    }

    private func loadMyAvatar() {
        Task {
            do {
                let profile = try await api.fetchMyProfile()

                guard let urlString = profile.avatar_url,
                      let url = URL(string: urlString) else { return }

                let (data, _) = try await URLSession.shared.data(from: url)

                await MainActor.run {
                    self.userProfileImg.image = UIImage(data: data)
                }
            } catch {
                print("Error loading profile image:", error)
            }
        }
    }
}

