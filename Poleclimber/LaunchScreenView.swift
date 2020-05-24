//
//  LaunchScreenView.swift
//  Poleclimber
//
//  Created by Babu on 24/05/2020.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import Foundation
import RevealingSplashView

class LaunchScreenView: UIViewController {
    
    @IBOutlet weak var launchView: UIView!

override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize a revealing Splash with with the iconImage, the initial size and the background color
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "openreach_logo")!, iconInitialSize: CGSize(width: 50, height: 50), backgroundImage: UIImage(named: "whiteBkg")!)

        revealingSplashView.useCustomIconColor = false
        revealingSplashView.animationType = SplashAnimationType.twitter
        revealingSplashView.iconColor = UIColor.clear
        revealingSplashView.duration = 2.5
    
        //Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)

        //Starts animation
        revealingSplashView.startAnimation(){
            print("Completed")
            
            let vc = UIStoryboard.storyboard(name: "Login").instantiateViewController(withIdentifier: "LoginViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
}
