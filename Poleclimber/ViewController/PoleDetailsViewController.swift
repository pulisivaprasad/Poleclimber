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
    @IBOutlet weak var cityTFiled: UITextField!
    @IBOutlet weak var stateTFiled: UITextField!
    @IBOutlet weak var countryTField: UITextField!
    @IBOutlet weak var zipCodeTField: UITextField!
    @IBOutlet weak var latitudeTField: UITextField!
    @IBOutlet weak var longitudeTField: UITextField!

    var placeHolderArr = ["Exchange Area", "DP Number", "CP Number", "City", "State", "Country", "Latitude", "Longitude"]

    var textFiledDataDisc = [String: String]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.locationManager.delegate = self
      self.navigationController?.isNavigationBarHidden = false
        self.title = "Pole Details"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        latitudeTField?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        longitudeTField?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))       
    }
    
    @objc func doneButtonTappedForMyNumericTextField() {
        print("Done");
        latitudeTField.resignFirstResponder()
        longitudeTField.resignFirstResponder()

    }
    
    func getAddress(street: String, city: String, state: String, country: String, zipcode: String) {
        cityTFiled.text = city
        stateTFiled.text = state
        countryTField.text = country
        zipCodeTField.text = zipcode
        
        latitudeTField.text = "\(appDelegate.locationManager.locationManager.location?.coordinate.latitude ?? 0.0)"
        longitudeTField.text = "\(appDelegate.locationManager.locationManager.location?.coordinate.longitude ?? 0.0)"
        
        textFiledDataDisc[(cityTFiled.placeholder?.replacingOccurrences(of: "*", with: ""))!] = cityTFiled.text
        textFiledDataDisc[(stateTFiled.placeholder?.replacingOccurrences(of: "*", with: ""))!] = stateTFiled.text
        textFiledDataDisc[(countryTField.placeholder?.replacingOccurrences(of: "*", with: ""))!] = countryTField.text
        textFiledDataDisc[(zipCodeTField.placeholder?.replacingOccurrences(of: "*", with: ""))!] = zipCodeTField.text
        textFiledDataDisc[(latitudeTField.placeholder?.replacingOccurrences(of: "*", with: ""))!] = latitudeTField.text
        textFiledDataDisc[(longitudeTField.placeholder?.replacingOccurrences(of: "*", with: ""))!] = longitudeTField.text
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

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() {
        self.resignFirstResponder()
        
    }
    @objc func cancelButtonTapped() {
        self.resignFirstResponder()
        
    }
}
