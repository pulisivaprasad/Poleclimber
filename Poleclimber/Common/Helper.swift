//
//  Helper.swift
//  eLegal
//
//  Created by Sivaprasadreddy Puli on 22/07/17.
//  Copyright © 2017 KP Tech. All rights reserved.
//

import UIKit

class Helper: NSObject  {
    static let sharedHelper = Helper()
    var appDel : AppDelegate;
    
    override init() {
        
        self.appDel = UIApplication.shared.delegate as! AppDelegate
    }
    
    func validateEmailWithString(_ checkString : NSString) -> Bool {
        
        let laxString = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*" as String
        let emailTest = NSPredicate(format:"SELF MATCHES %@",laxString) as NSPredicate
        return emailTest.evaluate(with: checkString)
    }
    
    func showGlobalAlertwithMessage(_ str : String, title: String) {
        
        DispatchQueue.main.async(execute: {
            let window:UIWindow = UIApplication.shared.windows.last!
            let alertView = UIAlertController(title: title, message: str as String, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            window.rootViewController!.present(alertView, animated: true, completion: nil)
        })
    }
    
    func showGlobalAlertwithMessage(_ str : String, vc: UIViewController, completion: (() -> Swift.Void)? = nil) {
        
        DispatchQueue.main.async(execute: {
            let alertView = UIAlertController(title: "Error", message: str as String, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: {             alert -> Void in
                
                completion?()
            }))
            vc.present(alertView, animated: true, completion: nil)
        })
    }
    
    class func dropShadow(view: UIView, upOrDown: Bool) {
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        
        if upOrDown {
            view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        }
        else {
            view.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
        }
        view.layer.shadowRadius = 2
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    }
    
    class func dateStringFromInt(dateInt: TimeInterval?, formatter: String = "dd MMM") -> String? {
        
        if let dataI = dateInt {
            
            let converted = NSDate(timeIntervalSince1970: TimeInterval(dataI / 1000))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = NSTimeZone.local
            dateFormatter.dateFormat = "dd MMM"
            let time = dateFormatter.string(from: converted as Date)
            return time
        }
        
        return ""
    }
    
    func showGlobalHUD(title: NSString, view: UIView) {
        let HUD = MBProgressHUD.showAdded(to: view, animated: true)
        HUD.label.text = title as String
    }

    func dismissHUD(view: UIView) {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func isNetworkAvailable() -> Bool
    {
        let rechability = Reachability()
        
        if (rechability?.isReachable)!
        {
            return true
        }
        else
        {
            return false
        }
    }

    func ShowAlert(str : NSString , viewcontroller:UIViewController) {
        let alertView = UIAlertController(title: "Poleclimber", message: str as String, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        viewcontroller.navigationController?.present(alertView, animated: true, completion: nil)
    }
    
    func generateName() -> String {
           let date = Date()
           let formater = DateFormatter()
           formater.dateFormat = "dd:MM:yyyy:mm:ss:SSS"
           let DateStr = formater.string(from: date) as String
           return DateStr.replacingOccurrences(of: ":", with: "")
       }
}


extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension String {
    
    func stringKey() -> String {
        
        var key = self.replacingOccurrences(of: "@", with: "")
        key = key.replacingOccurrences(of: ".", with: "")
        return key
    }
}

