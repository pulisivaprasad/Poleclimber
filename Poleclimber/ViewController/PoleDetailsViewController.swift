//
//  PoleDetailsViewController.swift
//  Poleclimber
//
//  Created by Siva Preasad Reddy on 24/05/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

class PoleDetailsViewController: UIViewController, LocationManagerDelegate {

    @IBOutlet weak var exchangeAreaTField: UITextField!
    @IBOutlet weak var dpNumberTFiled: UITextField!
    @IBOutlet weak var cpNumberTFiled: UITextField!
    @IBOutlet weak var streetTField: UITextField!
    @IBOutlet weak var cityTFiled: UITextField!
    @IBOutlet weak var stateTFiled: UITextField!
    @IBOutlet weak var countryTField: UITextField!
    @IBOutlet weak var zipCodeTField: UITextField!
    private let locationManager = LocationManager()
    var placeHolderArr = ["Exchange Area", "DP Number", "CP Number", "Street", "City", "State", "Country"]

    var textFiledDataDisc = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
      self.navigationController?.isNavigationBarHidden = false
        self.title = "Pole Details"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func getAddress(street: String, city: String, state: String, country: String, zipcode: String) {
        streetTField.text = street
        cityTFiled.text = city
        stateTFiled.text = state
        countryTField.text = country
        zipCodeTField.text = zipcode
        
        textFiledDataDisc[(streetTField.placeholder?.replacingOccurrences(of: "*", with: ""))!] = streetTField.text
        textFiledDataDisc[(cityTFiled.placeholder?.replacingOccurrences(of: "*", with: ""))!] = cityTFiled.text
        textFiledDataDisc[(stateTFiled.placeholder?.replacingOccurrences(of: "*", with: ""))!] = stateTFiled.text
        textFiledDataDisc[(countryTField.placeholder?.replacingOccurrences(of: "*", with: ""))!] = countryTField.text
        textFiledDataDisc[(zipCodeTField.placeholder?.replacingOccurrences(of: "*", with: ""))!] = zipCodeTField.text

    }
    
    @IBAction func continueBtnAction(sender: UIButton) {
        for keyString in placeHolderArr {
            let discObj = textFiledDataDisc[keyString]
            
            if discObj == "" || discObj == nil{
                Helper.sharedHelper.showGlobalAlertwithMessage("Please enter the \(keyString).", title: "Error")
                return
            }
        }
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
               let viewController = sb.instantiateViewController(withIdentifier: "ObjectDetectionViewController") as! ObjectDetectionViewController
        viewController.textFiledDataDisc = textFiledDataDisc
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension PoleDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
        let keyPlaceholder = textField.placeholder?.replacingOccurrences(of: "*", with: "")

        textFiledDataDisc[keyPlaceholder!] = textField.text
    }
}
