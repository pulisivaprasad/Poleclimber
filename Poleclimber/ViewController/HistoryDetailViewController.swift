//
//  HistoryDetailViewController.swift
//  Poleclimber
//
//  Created by Sivaprasad on 02/06/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class HistoryDetailViewController: UIViewController {

    @IBOutlet weak var updateddate: UILabel!
    @IBOutlet weak var feedbackReason: UILabel!
    @IBOutlet weak var exchangeArea: UILabel!
    @IBOutlet weak var dpNumber: UILabel!
    @IBOutlet weak var cpNumber: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var latAndLong: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tipTypeImg: UIImageView!

    var feedbackObj:Feedback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "History Details"
        
        if let imagename = feedbackObj?.image {
             let image = self.loadeImage(name: imagename)
            imageView.image = image
        }
        
        updateddate.text = feedbackObj?.date
        if feedbackObj?.reason != "NULL"{
            feedbackReason.text = feedbackObj?.reason
        }
        exchangeArea.text = "Exchange Area: " + (feedbackObj?.exchangeArea ?? "")
        dpNumber.text = "DP Number: " + (feedbackObj?.dpnumber ?? "")
        cpNumber.text = "CP Number: " + (feedbackObj?.cpnumber ?? "")
        address.text = "Address: " + feedbackObj!.gpsLocation!
        latAndLong.text = "Latitude: \(feedbackObj?.latitude ?? ""), Longitude: \(feedbackObj?.longitude ?? "")"
        
        
        
        if feedbackObj?.tipStatus == "Good Tip Detected"{
            tipTypeImg.image = UIImage(named: "good")
        }else{
            tipTypeImg.image = UIImage(named: "bad")
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
}
