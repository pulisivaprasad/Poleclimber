//
//  LogInViewController.swift
//  Poleclimber
//
//  Created by Suparno on 02/05/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var containerBottomConstrain: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        username.attributedPlaceholder =
        NSAttributedString(string: "username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        password.attributedPlaceholder =
        NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.keyboardNotification(notification:)),
        name: UIResponder.keyboardWillChangeFrameNotification,
        object: nil)
        
        self.navigationController?.navigationBar.isHidden = true
        
        configureBackground()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureBackground(){
        let gradient = CAGradientLayer()

        gradient.frame = view.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]

        backgroundImage.layer.insertSublayer(gradient, at: 0)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.containerBottomConstrain.constant = 40.0
            } else {
                self.containerBottomConstrain.constant = (endFrame?.size.height)!
            }
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    @IBAction func submitPressed(_ sender: Any) {
        performSegue(withIdentifier: "ToHomeScreen", sender: nil)
    }
}
