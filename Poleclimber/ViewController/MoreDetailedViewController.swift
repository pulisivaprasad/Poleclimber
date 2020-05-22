//
//  MoreDetailedViewController.swift
//  Poleclimber
//
//  Created by Babu on 22/05/2020.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import Foundation

class MoreDetailedViewController: UIViewController {
    
    @IBOutlet weak var detailedContentView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (self.title == "ABOUT")
        {
            self.detailedContentView?.attributedText = NSAttributedString(string:"\t\tConnecting you to the world\n\n\nWe run the UK's digital network. We're the people who connect homes, mobile phone masts, schools, shops, banks, hospitals, libraries, broadcasters, governments and businesses – large and small – to the world.It's our mission to build the best possible network with the highest quality of service, and make sure that everyone in the UK can be connected.")
            self.detailedContentView?.font = UIFont(name: "Helvetica Neue", size: 17)
        }
        else if (self.title == "HELP")
        {
            self.detailedContentView?.attributedText = NSAttributedString(string:"We work hard to get things right, but if you're unhappy we want to hear from you.  You can get in touch using our online form, and one of our dedicated advisors will get back to you within five working days.")
            self.detailedContentView?.font = UIFont(name: "Helvetica Neue", size: 17)
        }
        else if (self.title == "LEGAL AGREEMENT")
        {
            self.detailedContentView?.attributedText = loadPage()
        }
    }
    
    
    func loadPage() -> NSMutableAttributedString?
    {
        var attributedText : NSMutableAttributedString?
        var articlePara : String?
        
        if let path = Bundle.main.path(forResource: "Legal_info", ofType: "txt") {
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

}
