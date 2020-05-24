//
//  MoreDetailedViewController.swift
//  Poleclimber
//
//  Created by Babu on 22/05/2020.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import Foundation
import MessageUI

class MoreDetailedViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var detailedContentView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (self.title == "ABOUT US")
        {
            //Need to update our dedicated About content
            self.detailedContentView?.attributedText = loadPage(path:"About")
        }
        else if (self.title == "HELP")
        {
            self.navigationController?.popViewController(animated: false)
        }
        else if (self.title == "LEGAL AGREEMENT")
        {
            //Need to update our dedicated legal agreement content
            self.detailedContentView?.attributedText = loadPage(path:"Legal_info")
        }
        else if (self.title == "FEEDBACK")
        {
            self.sendEmail()
        }
    }
    
    
    func loadPage(path:String) -> NSMutableAttributedString?
    {
        var attributedText : NSMutableAttributedString?
        var articlePara : String?
        
        if let path = Bundle.main.path(forResource:path,ofType:"txt") {
            do {
                articlePara =  try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                if let htmlData = articlePara?.data(using: String.Encoding.unicode) {

                    let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
                    NSAttributedString.DocumentType.html]
                    
                    attributedText = try NSMutableAttributedString(data: htmlData, options: options, documentAttributes: nil)
                }
                
            }
            catch {
                print("Failed to read text from legal_info")
            }
        }
        
        attributedText?.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Helvetica Neue", size: 15)!, range: NSMakeRange(0, (attributedText?.length)!))
        return attributedText

    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["you@yoursite.com"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
            
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}

