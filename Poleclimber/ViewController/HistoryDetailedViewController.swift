//
//  HistoryDetailedViewController.swift
//  Poleclimber
//
//  Created by Babu on 24/05/2020.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import Foundation

class HistoryDetailedViewController: UIViewController {
    
    @IBOutlet weak var tipTypeImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var shareOption: UIButton!
    var detailedDict : Feedback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (detailedDict != nil)
        {
            if let imagename = detailedDict?.image {
                let image = self.loadeImage(name: imagename)
                tipTypeImg.image = image?.resize(CGSize(width: self.view.frame.width, height: 250))
            }

            titleLabel.text = detailedDict?.exchangeArea
            reasonLabel.text = detailedDict?.gpsLocation
        }

    }

    private func loadeImage(name: String) -> UIImage? {
           guard let documentsDirectory = try? FileManager.default.url(for: .documentDirectory,
                                                                           in: .userDomainMask,
                                                                           appropriateFor:nil,
                                                                           create:false)
                           else {
                               // May never happen
                               print ("No Document directory Error")
                               return nil
                           }

           // Construct your Path from device Documents Directory
           var imagesDirectory = documentsDirectory

           // Add your file name to path
           imagesDirectory.appendPathComponent(name)

           // Create your UIImage?
           let result = UIImage(contentsOfFile: imagesDirectory.path)
           
           return result
       }
    
    
    @IBAction func shareAction(_ sender: UIButton?)
    {
        
        let textToShare = "I'd like to share these poleClimber information to Openreach Engineer"
        let myWebsite = NSURL(string: "https://www.openreach.com/")!

        let objectsToShare = [textToShare, myWebsite] as [Any]
        let avc = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }

}
