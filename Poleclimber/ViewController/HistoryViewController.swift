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
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyObj.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!

        // set the text from the data model
        let historyDisc = historyObj[indexPath.row]
        
        cell.textLabel?.text = historyDisc["title"] as? String
        if let objectdetectDate = historyDisc["time"] {
            cell.detailTextLabel?.text = "\(objectdetectDate)"
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
