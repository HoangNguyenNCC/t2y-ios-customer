//
//  SignupViewController+Extension.swift
//  Trailer2You
//
//  Created by Aritro Paul on 03/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit

extension SignupViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == DLTextField {
            self.performSegue(withIdentifier: "DL", sender: Any?.self)
        }
        else if textField == dobTextField {
            datePickerView.datePickerMode = .date
            
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
            let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: #selector(donePressed))
            toolBar.setItems([cancelBarButton, flexibleSpace, doneBarButton], animated: true)
            textField.inputAccessoryView = toolBar
            
            textField.becomeFirstResponder()
        }
        else if textField == addressTextField {
            self.performSegue(withIdentifier: "address", sender: Any?.self)
        }
    }
    
}
