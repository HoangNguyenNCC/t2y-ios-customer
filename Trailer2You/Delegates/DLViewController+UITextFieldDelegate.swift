//
//  DLViewController+UITextFieldDelegate.swift
//  Trailer2You
//
//  Created by Aritro Paul on 24/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit

extension DLViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == expiryTextField {
            textField.inputView = datePickerView
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
            let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: #selector(donePressed))
            toolBar.setItems([cancelBarButton, flexibleSpace, doneBarButton], animated: true)
            textField.inputAccessoryView = toolBar
            textField.becomeFirstResponder()
        }
        
        if textField == stateTextField {
            textField.inputView = thePicker
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
            toolBar.barTintColor = .secondarySystemBackground
            thePicker.backgroundColor = .secondarySystemBackground
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
            let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: #selector(selectState))
            toolBar.setItems([cancelBarButton, flexibleSpace, doneBarButton], animated: true)
            textField.inputAccessoryView = toolBar
            textField.becomeFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: 0, y: -30, width: self.frame.width, height: self.frame.height)
        }
    }
}
