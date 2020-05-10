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
         let fetchedFeedbackData = DataManager.sharedInstance.retrieveSavedFeedback()
          print(fetchedFeedbackData as Any)
         acceptanceArray = fetchedFeedbackData!.filter{$0.userAcceptance == "Ok"}
         declinedArray = fetchedFeedbackData!.filter{$0.userAcceptance != "Ok"}
         collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.isNavigationBarHidden = false
//        if let object = UserDefaults.standard.object(forKey: "AGREEUSERDETAILS") {
//            historyObj = object as! [[String : AnyObject]]
//        }
        self.title = "History"
        fetchFeedback()

        segmentControl.selectedSegmentIndex = 0
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
        
        var feedbackObj:Feedback?
        if isShowingAcceptedList{
            feedbackObj = acceptanceArray![indexPath.row]
            cell.reasonLabel.isHidden = true
        }else{
            cell.reasonLabel.isHidden = false
            feedbackObj = declinedArray![indexPath.row]
        }
        
//
//        if segmentControl.selectedSegmentIndex == 1 {
//                   cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCellIdentifer2", for: indexPath) as! HistoryCell
//        }
        cell.dummyLabel.isHidden = true
        
        
            
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
            cell.imgView.image = image?.resize(CGSize(width: cellWidth, height: cellWidth))
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

       return CGSize(width: size, height: size)
   }
    
}

class HistoryCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tipTypeImg: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var dummyLabel: UILabel!
    


}



