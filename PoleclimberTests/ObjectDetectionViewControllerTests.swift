//
//  ObjectDetectionViewControllerTests.swift
//  PoleclimberTests
//
//  Created by Sivaprasad on 28/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import XCTest
@testable import Poleclimber

class ObjectDetectionViewControllerTests: XCTestCase {
  var sut: ObjectDetectionViewController!
    
    override func setUp() {
        setupViewController()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func setupViewController() {
           let bundle = Bundle.main
           let stroryboard = UIStoryboard(name: "Main", bundle: bundle)
           sut = stroryboard.instantiateViewController(withIdentifier: "ObjectDetectionViewController") as? ObjectDetectionViewController
           sut.loadViewIfNeeded()

       }
}
