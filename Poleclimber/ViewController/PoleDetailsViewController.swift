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

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func getAddress(street: String, city: String, state: String, country: String, zipcode: String) {
        cityTFiled.text = city
        stateTFiled.text = state
        countryTField.text = country
        zipCodeTField.text = zipcode
        streetTField.text = street

    }
    
}
