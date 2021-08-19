//
//  ChangePasswordViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 11/05/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import SPAlert

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        oldPasswordTextField.setPadding()
        newPasswordTextField.setPadding()
        oldPasswordTextField.layer.cornerRadius = 8
        newPasswordTextField.layer.cornerRadius = 8
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func validate() -> Bool{
        if oldPasswordTextField.text == "" {
            SPAlert.present(message: "Enter old password", haptic: .error)
            return false
        }
        if newPasswordTextField.text == "" {
            SPAlert.present(message: "Enter new Password", haptic: .error)
            return false
        }
        return true
    }
    
    @IBAction func changeTapped(_ sender: Any) {
        if validate() {
            let alert = showLoadingAlert(viewController: self, title: "Changing Password")
            ServiceController.shared.changePassword(oldPassword: oldPasswordTextField.text!, newPassword: newPasswordTextField.text!) { (status, error) in
                if status {
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true) {
                            SPAlert.present(title: "Success", message: "Password Changed", preset: .done)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true) {
                            SPAlert.present(message: error, haptic: .error)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
