import UIKit

protocol AddReviewTableViewCellDelegate: AnyObject {
    func presentFromCell(_ viewController: UIViewController, animated: Bool)
    func didPickImage(_ image: UIImage)
    func sendReview(rating: Int, comment: String?, wasPresent: Bool, image: UIImage?)
}

final class AddReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var imageUploaded: UIImageView!
    @IBOutlet weak var trashBtn: UIButton!
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var wasPresent: UISwitch!
    @IBOutlet weak var addImgButton: UIButton!
    @IBOutlet weak var star5: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star1: UIButton!

    weak var delegate: AddReviewTableViewCellDelegate?

    var allStars: [UIButton] { [star1, star2, star3, star4, star5] }
    var image: UIImage? = nil
    var starStates: [Int] = [0, 0, 0, 0, 0]

    override func awakeFromNib() {
        super.awakeFromNib()
        imageUploaded.isHidden = true
        trashBtn.isHidden = true
        self.layer.borderColor = UIColor.white.cgColor
    }

    func updateStars(star: Int) {
        for i in 0..<star {
            starStates[i] = 2
            allStars[i].setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        switch starStates[star] {
        case 1:
            starStates[star] = 2
            allStars[star].setImage(UIImage(systemName: "star.fill"), for: .normal)
        case 2:
            starStates[star] = 0
            allStars[star].setImage(UIImage(systemName: "star"), for: .normal)
        default:
            starStates[star] = 1
            allStars[star].setImage(UIImage(systemName: "star.leadinghalf.filled"), for: .normal)
        }
        for i in star+1..<allStars.count {
            starStates[i] = 0
            allStars[i].setImage(UIImage(systemName: "star"), for: .normal)
        }
    }

    @IBAction func star1_pressed(_ sender: Any) { updateStars(star: 0) }
    @IBAction func star2_pressed(_ sender: Any) { updateStars(star: 1) }
    @IBAction func star3_pressed(_ sender: Any) { updateStars(star: 2) }
    @IBAction func star4_pressed(_ sender: Any) { updateStars(star: 3) }
    @IBAction func star5_pressed(_ sender: Any) { updateStars(star: 4) }

    @IBAction func addImgPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.openImagePicker(source: .camera)
            })
        }

        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openImagePicker(source: .photoLibrary)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        delegate?.presentFromCell(alert, animated: true)
    }

    func openImagePicker(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        picker.allowsEditing = true
        delegate?.presentFromCell(picker, animated: true)
    }

    @IBAction func trashBtnPressed(_ sender: Any) {
        image = nil
        trashBtn.isHidden = true
        imageUploaded.isHidden = true
        addImgButton.isEnabled = true
    }

    @IBAction func sendBtnPressed(_ sender: Any) {
        let rating: Int = starStates.reduce(0, +)
        let commentText: String? = comment.text
        let wasPresentValue: Bool = wasPresent.isOn
        delegate?.sendReview(rating: rating, comment: commentText, wasPresent: wasPresentValue, image: image)
    }
}

extension AddReviewTableViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        var selectedImage: UIImage?

        if let image = info[.editedImage] as? UIImage {
            selectedImage = image
        } else if let image = info[.originalImage] as? UIImage {
            selectedImage = image
        }

        if let finalImage = selectedImage {
            delegate?.didPickImage(finalImage)
            imageUploaded.isHidden = false
            trashBtn.isHidden = false
            image = finalImage
            addImgButton.isEnabled = false
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
