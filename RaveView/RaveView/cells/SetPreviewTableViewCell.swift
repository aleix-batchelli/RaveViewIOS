import UIKit

final class SetPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var ArtistName: UILabel!
    @IBOutlet weak var numReviews: UILabel!
    @IBOutlet weak var SCorYT: UIImageView!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var DjSetName: UILabel!

    private var blurView: UIVisualEffectView!

    override func awakeFromNib() {
        super.awakeFromNib()

        img.layer.borderColor = UIColor.white.cgColor
        img.layer.borderWidth = 1
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill

        let blur = UIBlurEffect(style: .dark)
        blurView = UIVisualEffectView(effect: blur)
        blurView.frame = img.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0.6
        img.addSubview(blurView)

        DjSetName.textColor = .white
        ArtistName.textColor = .white
        numReviews.textColor = .white
        score.textColor = .white

        SCorYT.tintColor = .white
        SCorYT.image = SCorYT.image?.withRenderingMode(.alwaysTemplate)

        
        DjSetName.font = .boldSystemFont(ofSize: DjSetName.font.pointSize)
        score.font = .boldSystemFont(ofSize: score.font.pointSize)
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        img.image = UIImage(named: "placeholder")
    }

    func configure(with set: DJSet) {
        DjSetName.text = set.title
        ArtistName.text = set.artist_name
        numReviews.text = "\(set.ratings_count ?? 0)"
        score.text = set.avg_rating.map { String(format: "%.1f", $0) } ?? "-"

        switch set.platform.lowercased() {
        case "youtube":
            SCorYT.image = UIImage(named: "youtube")
        case "soundcloud":
            SCorYT.image = UIImage(named: "soundcloud")
        case "mixcloud":
            SCorYT.image = UIImage(named: "mixcloud")
        default:
            SCorYT.image = nil
        }

        if let s = set.thumbnail_url, let url = URL(string: s) {
            img.loadAndCropToImageView(url: url, placeholder: UIImage(named: "placeholder"))
        }
    }
}
