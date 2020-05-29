//
//  ToolbarPickerView.swift
//  Poleclimber
//
//  Created by Sivaprasad on 28/05/20.
//  Copyright © 2020 Siva Preasad Reddy. All rights reserved.
//

import UIKit

protocol ToolbarPickerViewDelegate: class {
    func didTapDone(selectedObject: String)
//    func didTapCancel()
}

class ToolbarPickerView: UIPickerView {
    var listArr = [String]()
    public private(set) var toolbar: UIToolbar?
       public weak var toolbarDelegate: ToolbarPickerViewDelegate?

       override init(frame: CGRect) {
           super.init(frame: frame)
           self.commonInit()
       }

       required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           self.commonInit()
       }

       private func commonInit() {
        
        
        self.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.backgroundColor = UIColor.groupTableViewBackground

        var toolBar = UIToolbar()
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))

           toolBar.barStyle = UIBarStyle.default
           toolBar.isTranslucent = true
           toolBar.tintColor = .black
           toolBar.sizeToFit()

           let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
           let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
           let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))

           toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
           toolBar.isUserInteractionEnabled = true

        
        self.dataSource = self
        self.delegate = self

        self.reloadAllComponents()
        self.toolbar = toolBar
       }
    
    func sePickerdata(poleType: String) {
        if poleType == "Good" {
            listArr = ["Rot present on the pole tip", "Side chipping looks like rot"]
        }
        else{
            listArr = ["Cracks on tip are natural", "Tip covered by bird droppings", "Chipping on tip is not rot"]
        }
    }

       @objc func doneTapped() {
          let row = self.selectedRow(inComponent: 0)
          self.selectRow(row, inComponent: 0, animated: false)
        self.toolbarDelegate?.didTapDone(selectedObject: self.listArr[row])
        self.removeFromSuperview()
        self.toolbar?.removeFromSuperview()

       }

       @objc func cancelTapped() {
        self.removeFromSuperview()
        self.toolbar?.removeFromSuperview()

          // self.toolbarDelegate?.didTapCancel()
       }
}

extension ToolbarPickerView: UIPickerViewDataSource, UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.listArr.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.listArr[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //self.textField.text = self.titles[row]
    }
}
