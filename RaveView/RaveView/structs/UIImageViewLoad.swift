//
//  UIImageViewLoad.swift.swift
//  RaveView
//
//  Created by Aniol Vergés Herrera on 22/1/26.
//

import UIKit

extension UIImageView {

    func loadAndCropToImageView(url: URL, placeholder: UIImage? = nil) {
        image = placeholder

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard
                let self,
                let data,
                let downloaded = UIImage(data: data)
            else { return }

            DispatchQueue.main.async {
                // Ensure layout is applied so bounds are correct
                self.layoutIfNeeded()

                // Crop to the current imageView aspect ratio
                let targetSize = self.bounds.size
                if targetSize.width > 0, targetSize.height > 0,
                   let cropped = downloaded.croppedToAspectFill(targetSize: targetSize) {
                    self.image = cropped
                } else {
                    self.image = downloaded
                }
            }
        }.resume()
    }
}

extension UIImage {

    /// Crops the image to fill the targetSize aspect ratio (center crop).
    func croppedToAspectFill(targetSize: CGSize) -> UIImage? {
        guard let cg = self.cgImage else { return nil }

        let imgW = CGFloat(cg.width)
        let imgH = CGFloat(cg.height)
        let imgAspect = imgW / imgH

        let targetAspect = targetSize.width / targetSize.height

        var cropRect: CGRect

        if imgAspect > targetAspect {
            // Image is wider than target: crop left/right
            let newWidth = imgH * targetAspect
            let x = (imgW - newWidth) / 2
            cropRect = CGRect(x: x, y: 0, width: newWidth, height: imgH)
        } else {
            // Image is taller than target: crop top/bottom
            let newHeight = imgW / targetAspect
            let y = (imgH - newHeight) / 2
            cropRect = CGRect(x: 0, y: y, width: imgW, height: newHeight)
        }

        guard let croppedCG = cg.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: croppedCG, scale: self.scale, orientation: self.imageOrientation)
    }
}

