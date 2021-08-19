//
//  ResetPasswordViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 11/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import SPAlert

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var tokenField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var viewToggle: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var email = ""
    var isHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .light
        tokenField.addIcon(iconName: "centsign.circle.fill")
        passwordField.addIcon(iconName: "lock.fill")
        
        print(email)
        tokenField.layer.cornerRadius = 8
        passwordField.layer.cornerRadius = 8
        confirmButton.layer.cornerRadius = confirmButton.frame.height/2
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func togglePasswordView(_ sender: Any) {
        isHidden = !isHidden
        passwordField.isSecureTextEntry = !isHidden
        
    }
    
    func resetPassword() {
        ServiceController.shared.resetPassword(token: tokenField.text ?? "", password: passwordField.text ?? "") { (status, error) in
            DispatchQueue.main.async {
                if status {
                    self.dismiss(animated: true) {
                        //
                    }
                }
                else {
                    self.showErrorAlert(title: "Error", subtitle: error.errors?[0] ?? "Error", viewController: self)
                }
            }

        }
    }
    
    func forgotPassword() {
        ServiceController.shared.forgotPassword(email: email) { (status, error) in
            print(status)
            DispatchQueue.main.async {
                if status {
                    SPAlert.present(title: "Email sent again", preset: .done)
                }
                else {
                    self.showErrorAlert(title: "Error", subtitle: error.errors?[0] ?? "Error", viewController: self)
                }
            }
        }
    }
    
    func validate() -> Bool {
        if passwordField.text == "" {
            SPAlert.present(message: "Password should contain 1 Capital Letter, 1 small letter, 1 digit and 1 special character", haptic: .error)
               return false
            }
        let passwordRegex = "^(?=.*[A-Z]+)(?=.*[!@#$&*]+)(?=.*[0-9]+)(?=.*[a-z]+).{8,20}$"
        if NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: passwordField.text) == false{
            SPAlert.present(message: "Password should contain 1 Capital Letter, 1 small letter, 1 digit and 1 special character", haptic: .error)
            return false
        }
       if passwordField.text?.count ?? 0 < 8 {
           SPAlert.present(message: "Password length should be more than 8 characters", haptic: .error)
           return false
       }
        return true
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        if validate() {
            resetPassword()
        }
    }
    
    
    @IBAction func resendTapped(_ sender: Any) {
        forgotPassword()
    }
}
