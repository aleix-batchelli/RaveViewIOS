import UIKit

final class ProfileInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var numReviews: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var UserNameId: UILabel!
    @IBOutlet weak var UserNameVisible: UILabel!

    weak var delegate: ProfileInfoTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        profileImg.layer.cornerRadius = profileImg.bounds.height / 2
        profileImg.clipsToBounds = true

        logOutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    func configure(profile: Profile, reviewsCount: Int) {
        UserNameId.text = "@\(profile.username)"
        UserNameVisible.text = profile.display_name ?? profile.username
        numReviews.text = "\(reviewsCount)"

        if let urlString = profile.avatar_url,
           let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImg.image = UIImage(systemName: "person.crop.circle")
        }
    }

    @IBAction func logoutTapped(_ sender: Any) {
        print("Hols")
        delegate?.didTapLogout()
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
