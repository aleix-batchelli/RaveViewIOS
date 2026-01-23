import UIKit

// 1. Define a protocol so the Cell can talk to the View Controller
protocol AddReviewTableViewCellDelegate: AnyObject {
    func presentFromCell(_ viewController: UIViewController, animated: Bool)
    func didPickImage(_ image: UIImage) // Optional: To send the image back to the
    func sendReview(rating: Int, comment: String?, wasPresent: Bool, image: UIImage)
    
}

class AddReviewTableViewCell: UITableViewCell {
    
    // 2. Add the delegate variable
    @IBOutlet weak var imageUploaded: UIImageView!
    @IBOutlet weak var trashBtn: UIButton!
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var wasPresent: UISwitch!
    weak var delegate: AddReviewTableViewCellDelegate?

    @IBOutlet weak var addImgButton: UIButton!
    @IBOutlet weak var star5: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star1: UIButton!
    
    // Add an outlet for the image if you want to show it in the cell
    // @IBOutlet weak var selectedImageView: UIImageView!
    
    var allStars: [UIButton] {
        return [star1, star2, star3, star4, star5]
    }
    
    var image: UIImage = UIImage()
    
    var starStates: [Int] = [0, 0, 0, 0, 0]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageUploaded.isHidden = true
        trashBtn.isHidden = true
        self.layer.borderColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateStars(star: Int) {
        // (Your existing star logic remains unchanged)
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
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openImagePicker(source: .camera)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openImagePicker(source: .photoLibrary)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 3. FIX: Ask the delegate to present, don't do it yourself
        delegate?.presentFromCell(alert, animated: true)
    }

    func openImagePicker(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        picker.allowsEditing = true
        
        // 3. FIX: Ask the delegate to present the picker
        delegate?.presentFromCell(picker, animated: true)
    }
    @IBAction func trashBtnPressed(_ sender: Any) {
        image = UIImage()
        trashBtn.isHidden = true
        imageUploaded.isHidden = true
        addImgButton.isEnabled = true
    }
    
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        
        //send info to api
        let rating: Int = starStates.reduce(0, +)
        let comment: String? = comment.text
        let wasPresent: Bool = wasPresent.isOn
        delegate?.sendReview(rating: rating, comment: comment, wasPresent: wasPresent, image: image)
        
    }
}

extension AddReviewTableViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        if let image = info[.editedImage] as? UIImage {
            selectedImage = image
        } else if let image = info[.originalImage] as? UIImage {
            selectedImage = image
        }
        
        if let finalImage = selectedImage {
            print("Image selected in Cell")
            // Show the image in the cell if you have an imageView:
            // self.selectedImageView.image = finalImage
            
            // Pass the image up to the controller to save it
            delegate?.didPickImage(finalImage)
        }
        imageUploaded.isHidden = false
        trashBtn.isHidden = false
        image = selectedImage!
        addImgButton.isEnabled = false
        
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
