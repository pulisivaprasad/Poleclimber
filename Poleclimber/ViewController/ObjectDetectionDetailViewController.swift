//
//  ObjectDetectionDetailViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 07/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit
import Vision

class ObjectDetectionDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var subImgFrame = CGRect()
    var originlImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = self.cropImage(image: originlImg, normalisedRect: subImgFrame)
        imageView.image = img
    }
    
    func cropImage(image: UIImage, normalisedRect: CGRect) -> UIImage? {
        let objectBounds = VNImageRectForNormalizedRect(normalisedRect, Int(image.size.width), Int(image.size.height))
         let x = normalisedRect.origin.x * image.size.width
         let y = normalisedRect.origin.y * image.size.height
         let width = normalisedRect.width * image.size.width
         let height = normalisedRect.height * image.size.height

           let rect = CGRect(x: x, y: y, width: width, height: height)

         guard let cropped = image.cgImage?.cropping(to: objectBounds) else {
           return nil
         }

         let croppedImage = UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
         return croppedImage
    }


}
