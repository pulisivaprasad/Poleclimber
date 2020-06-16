//
//  HomeViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 18/03/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController {
   
    @IBOutlet weak var startBtn: UIButton!
    var feedbackArr:[Feedback]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
     override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.navigationController?.isNavigationBarHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        fetchFeedback()
            
    }
    
    func fetchFeedback() {
           guard let userID = userDefault.object(forKey: "USERNAME") as? String else { return

           }
           
           feedbackArr = DataManager.sharedInstance.retrieveSavedFeedbackWithLocalMLModel(userID: userID)
               
           guard feedbackArr != nil else{
               return
           }
        
        if feedbackArr!.count >= 10 {
            startBtn.backgroundColor = UIColor.lightGray
            startBtn.isUserInteractionEnabled = false
            
            let csvString = writeCoreObjectsToCSV(objects: feedbackArr!, named: (userDefault.object(forKey: "USERNAME") as? String)!)
            print(csvString)
            //let data = csvString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let url = URL(fileURLWithPath: path).appendingPathComponent((userDefault.object(forKey: "USERNAME") as? String)!)
            print(url)
            
            let contentfilename = (userDefault.object(forKey: "USERNAME") as? String)! + ".csv"
            
            //let audioUrl = URL(fileURLWithPath: "your audio local file path")
            AWSS3Manager.shared.uploadOtherFile(fileUrl: url, conentType: contentfilename, progress: { [weak self] (progress) in
            //uploadAudio(audioUrl: url, progress: { [weak self] (progress) in
                
                guard let strongSelf = self else { return }
                //strongSelf.progressView.progress = Float(progress)
                
            }) { [weak self] (uploadedFileUrl, error) in
                
                guard let strongSelf = self else { return }
                if let finalPath = uploadedFileUrl as? String {
                    //strongSelf.s3UrlLabel.text = "Uploaded file url: " + finalPath
                } else {
                    print("\(String(describing: error?.localizedDescription))")
                }
            }
        }
        else{
            startBtn.backgroundColor = pAppStatusBarColor
            startBtn.isUserInteractionEnabled = true
        }
           
    }
    
     // Takes a managed object and writes it to the .csv file ..?
     func writeCoreObjectsToCSV(objects: [Feedback], named: String) -> [String]
     {
     // Make sure we have some data to export
     guard objects.count > 0 else
     {
         return [""]
     }
         var feedbackArr = [String]()
         
         for feedbackObj in objects {
              let firstObject = feedbackObj
                let attribs = Array(firstObject.entity.attributesByName.keys)
                // The attires.reduce function is throwing an error about originally using combine as in the second post, used auto fix, but noteworthy.
                //Now gives an error that says "No '+' candidates produce the expected contextual result type NSString"
                    let csvHeaderString = (attribs.reduce("", {($0 as String) + "," + $1 }) as NSString).substring(from: 1) + "\n"
                // This function says that substring from index has been renamed as well as a few other lines within it
                let csvArray = objects.map({object in
                    (attribs.map({((object.value(forKey: $0) ?? "NIL") as AnyObject).description}).reduce("",{$0 + "," + $1}) as NSString).substring(from: 1) + "\n"
                })
                // Again with the reduce issue
                    let csvString = csvArray.reduce("", +)
             
             let savingCSVString = csvHeaderString + csvString
             
             let filemanager = FileManager.default
             let directory = filemanager.urls(for: .documentDirectory, in: .userDomainMask)[0]
             let path = directory.appendingPathComponent(named).appendingPathExtension("Text")
             if filemanager.fileExists(atPath: path.path) {
                 filemanager.createFile(atPath: path.path, contents: nil, attributes: nil)
             }
             do {
                 try savingCSVString.write(to: path, atomically: true, encoding: .utf8)
                        
             }catch let error {
                 print(error.localizedDescription)
             }
             
             feedbackArr.append(savingCSVString)
         }
    
       return feedbackArr
     }

       
       
    @IBAction func inspectionBtnAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
               let viewController = sb.instantiateViewController(withIdentifier: "PoleDetailsViewController") as! PoleDetailsViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
