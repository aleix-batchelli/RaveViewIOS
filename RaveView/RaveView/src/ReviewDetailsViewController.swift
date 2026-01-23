//
//  ReviewDetailsViewController.swift
//  RaveView
//
//  Created by Aleix Batchelli I Abad on 23/1/26.
//

import UIKit

class ReviewDetailsViewController: UIViewController {

    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var wasThere: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet weak var star0: UIImageView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    
    var stars: [UIImageView] {
        return [star0, star1, star2, star3, star4]
    }
    
    var review: ReviewWithProfile?
    private let api = DJSetsAPI(client: SupabaseManager.shared.client)

    override func viewDidLoad() {
        super.viewDidLoad()

        background.layer.borderColor = UIColor.white.cgColor
        username.text = review?.profiles.username
        wasThere.text = (review?.was_present == true) ? "I was there!" : ""
        date.text = review?.created_at.formatted(date: .abbreviated, time: .omitted) ?? "Unknown"
        fillStarts(rating: review?.rating ?? 0);
        reviewText.text = review?.comment
        
        loadReviewImageIfAny()

    }
    
    
    
    func fillStarts(rating: Int) {
        for i in 0..<5 {
            stars[i].image = UIImage(systemName: "star")
        }
        
        let count: Int = (review?.rating ?? 0) / 2
        print(count)
        let mod: Int = (review?.rating ?? 0) % 2
        print(mod)
        
        for i in 0..<count {
            stars[i].image = UIImage(systemName: "star.fill")
        }
        
        if mod == 1 {
            stars[count].image = UIImage(systemName: "star.leadinghalf.fill")
        }
        
        
    }
    
    private func loadReviewImageIfAny() {

            guard let reviewId = review?.id else { return }

            Task {
                do {
                    if let row = try await api.fetchReviewImage(forReviewId: reviewId),
                       let url = URL(string: row.url) {

                        let (data, _) = try await URLSession.shared.data(from: url)
                        let uiImage = UIImage(data: data)

                        await MainActor.run {
                            self.image.image = uiImage
                            self.image.isHidden = (uiImage == nil)
                        }
                    } else {
                        await MainActor.run {
                            self.image.image = nil
                            self.image.isHidden = true
                        }
                    }
                } catch {
                    // If fails, just hide image
                    await MainActor.run {
                        self.image.image = nil
                        self.image.isHidden = true
                    }
                    print("Error loading review image:", error)
                }
            }
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
