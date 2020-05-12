//
//  HistoryViewController.swift
//  Poleclimber
//
//  Created by Sivaprasad on 30/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

   // var historyObj = [[String: AnyObject]]()
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    var acceptanceArray:[Feedback]?
    var declinedArray:[Feedback]?
    var isShowingAcceptedList:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    func fetchFeedback() {
        guard let userID = userDefault.object(forKey: "USERNAME") as? String else { return

        }
        
        let fetchedFeedbackData = DataManager.sharedInstance.retrieveSavedFeedback(userID: userID)
            
        guard fetchedFeedbackData != nil else{
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyy hh:mm:ss a"
        acceptanceArray = fetchedFeedbackData!.sorted(by: {
            dateFormatter.date(from: $0.date!)?.compare(dateFormatter.date(from: $1.date!)!) == .orderedDescending
        })
        
        declinedArray = acceptanceArray!.filter{$0.userAcceptance != "Ok"}
         collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.isNavigationBarHidden = false

        self.title = "History"
        fetchFeedback()

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
    
    @IBAction func segmentConAction(_ sender: UISegmentedControl) {
//        if sender.selectedSegmentIndex == 0 {
//             if let object = UserDefaults.standard.object(forKey: "AGREEUSERDETAILS") {
//                historyObj = object as! [[String : AnyObject]]
//            }
//        }
//        else{
//             if let object = UserDefaults.standard.object(forKey: "DISAGREEUSERDETAILS") {
//                historyObj = object as! [[String : AnyObject]]
//            }
//        }
        isShowingAcceptedList = !isShowingAcceptedList
        collectionView.reloadData()
    }
}

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isShowingAcceptedList{
            return acceptanceArray?.count ?? 0
        }else{
            return declinedArray?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCellIdentifier", for: indexPath) as! HistoryCell
        
        cell.dummyLabel.isHidden = true
        cell.reasonLabel.isHidden = true

        
        var feedbackObj:Feedback?
        if isShowingAcceptedList{
            feedbackObj = acceptanceArray![indexPath.row]
        }else{
            feedbackObj = declinedArray![indexPath.row]
        }
        

        
        if feedbackObj?.reason != "NULL"{
            cell.reasonLabel.isHidden = false
            cell.reasonLabel.text = feedbackObj?.reason
        }
                    
        cell.reasonLabel.text = feedbackObj?.reason
        
        if feedbackObj?.tipStatus == "Good Tip Detected"{
            cell.tipTypeImg.image = UIImage(named: "good")
        }else{
            cell.tipTypeImg.image = UIImage(named: "bad")
        }

        
        if let objectdetectDate = feedbackObj?.date {
            cell.timeLabel?.text = "\(objectdetectDate)"
        }
        
        if let imagename = feedbackObj?.image {
            let image = self.loadeImage(name: imagename)
            let cellWidth = self.view.frame.width/2 - 15
            cell.imgView.image = image?.resize(CGSize(width: cellWidth, height: 200))
        }
                
        return cell
    }

//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        cellDidSelect(col: indexPath.row)
//    }
    

    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

       let noOfCellsInRow = 1

       let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

       let totalSpace = flowLayout.sectionInset.left
           + flowLayout.sectionInset.right
           + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

       let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

       return CGSize(width: size, height: 200)
   }
    
}

class HistoryCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tipTypeImg: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var dummyLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
   }

    


}


extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

