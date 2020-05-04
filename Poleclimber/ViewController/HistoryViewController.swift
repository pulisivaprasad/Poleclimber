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

    @IBOutlet var collectionView: UICollectionView!
    
    let reuseIdentifier = "HistoryCellIdentifer";
    
    private let sectionInsets = UIEdgeInsets(top: 5.0,
                                             left: 2.0,
                                             bottom: 5.0,
                                             right: 2.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.isNavigationBarHidden = false
        if let object = UserDefaults.standard.object(forKey: "USERDETAILS") {
            historyObj = object as! [[String : AnyObject]]
        }
        collectionView.reloadData()
        self.parent?.title = "History"

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
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")!

        // set the text from the data model
        let historyDisc = historyObj[indexPath.row]
        
        cell.textLabel?.text = historyDisc["title"] as? String
        if let objectdetectDate = historyDisc["time"] {
            cell.detailTextLabel?.text = "\(objectdetectDate)"
        }
        
        if let imagename = historyDisc["image"] as? String {
            let image = self.loadeImage(name: imagename)
        }

        return cell
    }
}

extension HistoryViewController: UICollectionViewDataSource {
    
    
    //UICollectionViewDatasource methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return historyObj.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HistoryCell
        // set the text from the data model
        let historyDisc = historyObj[indexPath.row]
        
//        cell.textLabel?.text = historyDisc["title"] as? String
        if let objectdetectDate = historyDisc["time"] {
            cell.timeStamp?.text = "\(objectdetectDate)"
        }

        cell.isGoodTip = historyDisc["isGood"] as? Bool ?? false
        
        if let imagename = historyDisc["image"] as? String {
            let image = self.loadeImage(name: imagename)
            let cellWidth = self.view.frame.width/2 - 2
            cell.imageView.image = image?.resize(CGSize(width: cellWidth, height: cellWidth * 1.5))
        }
        return cell
    }
}

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    //UICollectionViewDelegateFlowLayout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let cellWidth = self.view.frame.width/2 - 2
        return CGSize(width: cellWidth, height: cellWidth * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        
        return 2;
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        
        return 1;
    }
}


class HistoryCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var type: UILabel!
    var isGoodTip: Bool{
        didSet{
            if self.isGoodTip {
                type.text = "GOOD"
                type.backgroundColor = UIColor.green
            }
            else{
                type.text = "Bad"
                type.backgroundColor = UIColor.red
            }
        }
    }
    
    required init?(coder: NSCoder) {
        isGoodTip = false
        super.init(coder: coder)
    }
}
