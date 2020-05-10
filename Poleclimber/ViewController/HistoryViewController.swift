//
//  HistoryViewController.swift
//  Poleclimber
//
//  Created by Sivaprasad on 30/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    var historyObj = [[String: AnyObject]]()
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.isNavigationBarHidden = false
        historyObj.removeAll()

        if let object = UserDefaults.standard.object(forKey: "AGREEUSERDETAILS") {
            historyObj = object as! [[String : AnyObject]]
            if let object2 = UserDefaults.standard.object(forKey: "DISAGREEUSERDETAILS") {
                for disagreeObj in object2 as! [[String : AnyObject]] {
                    historyObj.append(disagreeObj)
                }
            }
        }
        self.title = "History"
        
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
        historyObj.removeAll()
        if sender.selectedSegmentIndex == 0 {
             if let object = UserDefaults.standard.object(forKey: "AGREEUSERDETAILS") {
                historyObj = object as! [[String : AnyObject]]
                if let object2 = UserDefaults.standard.object(forKey: "DISAGREEUSERDETAILS") {
                    for disagreeObj in object2 as! [[String : AnyObject]] {
                        historyObj.append(disagreeObj)
                    }
                }
            }
        }
        else{
             if let object = UserDefaults.standard.object(forKey: "DISAGREEUSERDETAILS") {
                historyObj = object as! [[String : AnyObject]]
            }
        }
        collectionView.reloadData()
    }
}

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return self.historyObj.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCellIdentifer", for: indexPath) as! HistoryCell
        
        let historyDisc =  self.historyObj[indexPath.row]

        if (historyDisc["reason"] as? String) != nil {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCellIdentifer2", for: indexPath) as! HistoryCell
            cell.reasonLabel.text = historyDisc["reason"] as? String
        }
        
        if historyDisc["tipStatus"] as? String == "Good Tip Detected" {
            cell.tipTypeImg.image = UIImage(named: "good")
        }
        else{
            cell.tipTypeImg.image = UIImage(named: "bad")
        }
        
        if let objectdetectDate = historyDisc["time"] {
            cell.timeLabel?.text = "\(objectdetectDate)"
        }
        
        if let imagename = historyDisc["image"] as? String {
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

       let noOfCellsInRow = 2

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

}


