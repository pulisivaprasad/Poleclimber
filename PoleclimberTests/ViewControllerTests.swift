//
//  ViewControllerTests.swift
//  Poleclimber
//
//  Created by Sivaprasad on 28/04/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import XCTest
@testable import Poleclimber

class ViewControllerTests: XCTestCase {
    
    var sut: ViewController!
    var window: UIWindow!
    
    override func setUp() {
        window = UIWindow()
        setupViewController()
    }

    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    func setupViewController() {
        let bundle = Bundle.main
        let stroryboard = UIStoryboard(name: "Main", bundle: bundle)
        sut = stroryboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        sut.loadViewIfNeeded()

    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    func testInspectionBtnAction() {
        let inspectionBtn: UIButton = sut.startBtn
        XCTAssertNotNil(inspectionBtn, "View Controller does not have UIButton property")
        
        // Attempt Access UIButton Actions
           guard let loginButtonActions = inspectionBtn.actions(forTarget: sut, forControlEvent: .touchUpInside) else {
               XCTFail("UIButton does not have actions assigned for Control Event .touchUpInside")
               return
           }
        
           // Assert UIButton has action with a method name
           XCTAssertTrue(loginButtonActions.contains("inspectionBtnAction:"))
           sut.startBtn.sendActions(for: .touchUpInside)
    }
    
}
