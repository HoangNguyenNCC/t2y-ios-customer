//
//  ForgotPasswordViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 11/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import SPAlert

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        emailField.addIcon(iconName: "person.circle.fill")
        
        //set borders
        emailField.layer.cornerRadius = 8
        resetButton.layer.cornerRadius = resetButton.frame.height/2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        email = emailField.text ?? ""
        if email == "" {
            SPAlert.present(message: "Email is empty", haptic: .error)
        }
        else {
            forgotPassword()
        }
    }
    
    func forgotPassword() {
        ServiceController.shared.forgotPassword(email: email) { (status, error) in
            print(status)
            DispatchQueue.main.async {
                if status {
                    self.performSegue(withIdentifier: "confirmReset", sender: Any?.self)
                }
                else {
                    self.showErrorAlert(title: "Error", subtitle: error.errors?[0] ?? "Error", viewController: self)
                }
            }
        }
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resetVC = segue.destination as? ResetPasswordViewController {
            resetVC.email = email
        }
    }


}
