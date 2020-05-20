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
    @IBOutlet weak var historyTableView: UITableView!

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
        historyTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       self.navigationController?.isNavigationBarHidden = false
       navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
        historyTableView.reloadData()
    }
    
    @IBAction func editBtnAction(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: historyTableView)
        let indexPath = self.historyTableView.indexPathForRow(at:buttonPosition)
        print(indexPath?.row ?? "")
        var feedbackObj:Feedback?
        if isShowingAcceptedList{
            feedbackObj = acceptanceArray![indexPath!.row]
        }else{
            feedbackObj = declinedArray![indexPath!.row]
        }
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Edit", style: .default) { _ -> Void in
            self.btnEditClick(feedbackDetails: feedbackObj!)
        }

//        let secondAction: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { _ -> Void in
//            self.btnDeleteClick(feedbackDetails: feedbackObj!)
//        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }

        // add actions
        actionSheetController.addAction(firstAction)
       // actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)

        if let presenter = actionSheetController.popoverPresentationController {
            presenter.sourceView = sender
            presenter.sourceRect = sender.bounds
        }

        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func btnEditClick(feedbackDetails: Feedback) {
        if feedbackDetails.originalImg != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ObjectDetectionViewController") as! ObjectDetectionViewController
            vc.feedbackObj = feedbackDetails
            vc.editPost = 1
            navigationController?.pushViewController(vc, animated: true)
        }
        else{
            Helper.sharedHelper.showGlobalAlertwithMessage("You don't have original image in this image.", vc: self)
        }
    }
    
    func btnDeleteClick(feedbackDetails: Feedback) {
        let alertController = UIAlertController(title: "", message: "Are you sure, you want to delete this post?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (_: UIAlertAction!) in
            //Helper.sharedHelper.showGlobalHUD(title: "Deleting post..", view: self.view)
            
            
        }))
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowingAcceptedList{
            return acceptanceArray?.count ?? 0
        }else{
            return declinedArray?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
               
        cell.reasonLabel.isHidden = true
        
        cell.subView.layer.cornerRadius = 6
        cell.subView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell.subView.layer.shadowColor = UIColor.black.cgColor
        cell.subView.layer.shadowOpacity = 0.3
        cell.subView.layer.shadowRadius = 4
        
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
        cell.poleTesterName.text = feedbackObj?.poleTesterID
               
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

class HistoryCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tipTypeImg: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var poleTesterName: UILabel!
    @IBOutlet weak var subView: UIView!
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

