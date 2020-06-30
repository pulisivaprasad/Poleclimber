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
        
        if feedbackArr!.count >= 5 {
            startBtn.backgroundColor = UIColor.lightGray
            startBtn.isUserInteractionEnabled = false
            Helper.sharedHelper.showGlobalAlertwithMessage("You have reached max limit of storing analyzed images by local ML model on the IPhone, you need to synchronize the images to the cloud for further usage of this Application.\nUse option Sync under profile section of this app to proceed.", title: "Alert", vc: self)
        }
        else{
            startBtn.backgroundColor = pAppStatusBarColor
            startBtn.isUserInteractionEnabled = true
        }
    }
       
    @IBAction func inspectionBtnAction(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
               let viewController = sb.instantiateViewController(withIdentifier: "PoleDetailsViewController") as! PoleDetailsViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
