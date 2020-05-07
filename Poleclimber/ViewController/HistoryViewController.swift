//
//  HistoryViewController.swift
//  Poleclimber
//
//  Created by Sivaprasad on 30/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var historyObj = [[String: AnyObject]]()
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.isNavigationBarHidden = false
        if let object = UserDefaults.standard.object(forKey: "AGREEUSERDETAILS") {
            historyObj = object as! [[String : AnyObject]]
        }
        tableview.reloadData()
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

    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyObj.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell

        // set the text from the data model
        let historyDisc = historyObj[indexPath.row]
        
        cell.tiprotstatus?.text = historyDisc["title"] as? String
        if let objectdetectDate = historyDisc["time"] {
            cell.timeLabel?.text = "\(objectdetectDate)"
        }
        
        if let imagename = historyDisc["image"] as? String {
            let image = self.loadeImage(name: imagename)
            cell.imgView.image = image
        }


        return cell
    }
    
    @IBAction func segmentConAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
             if let object = UserDefaults.standard.object(forKey: "AGREEUSERDETAILS") {
                historyObj = object as! [[String : AnyObject]]
            }
        }
        else{
             if let object = UserDefaults.standard.object(forKey: "DISAGREEUSERDETAILS") {
                historyObj = object as! [[String : AnyObject]]
            }
        }
        tableview.reloadData()

        
    }
}

class TableViewCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tiprotstatus: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

}


