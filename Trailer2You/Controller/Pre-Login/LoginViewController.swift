//
//  LoginViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 02/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import os
import SPAlert
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    
    /// Indicator to show `networking`
    let activity = UIActivityIndicatorView(style: .medium)
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        //update Status Bar style
        setNeedsStatusBarAppearanceUpdate()
        os_log(.info, log: .ui, "Login Loaded")
    }
    
    //MARK: - Subview Layouts
    override func viewDidLayoutSubviews() {
        //add icons to textFields
        emailTextField.addIcon(iconName: "person.circle.fill")
        passwordTextField.addIcon(iconName: "lock.fill")
        
        //set borders
        emailTextField.layer.cornerRadius = 8
        passwordTextField.layer.cornerRadius = 8
        loginButton.layer.cornerRadius = loginButton.frame.height/2
    }
    
    
    //MARK: ------ Login Flow -----
    
    ///BEGIN
    func loginWillBegin() {
        loginButton.setTitle("Logging in", for: .normal)
        loginButton.addSubview(activity)
        activity.center.x = (loginButton.titleLabel?.frame.minX ?? 20) - 40
        activity.center.y = loginButton.center.y
        activity.color = .white
        activity.startAnimating()
    }
    
    /// Networking
    func login() {
        ServiceController.shared.login(withEmail: emailTextField.text!, withPassword: passwordTextField.text!, completion: handleLogin(status:response:err:))
    }
    
    ///END
    func loginEnded() {
        activity.stopAnimating()
        activity.removeFromSuperview()
        loginButton.setTitle("Login", for: .normal)
    }
    
    
    
    //MARK: - Buttons
    @IBAction func loginTapped(_ sender: Any) {
        if validate() {
            loginWillBegin()
            os_log(.info, log: .network, "Starting Login")
            login()
        }
    }
    
    /// Login Handler
    func handleLogin(status:Bool,response:LoginResponse,err:Error){
        if status {
            token = response.dataObj?.token ?? ""
            user = response.dataObj?.userObj?._id ?? ""
            let email = response.dataObj?.userObj?.email ?? ""
            DispatchQueue.main.async {
                let password = self.passwordTextField.text!
                KeychainWrapper.standard.set(password,forKey: "password")
            }
                        
            KeychainWrapper.standard.set(email, forKey: "email")
            KeychainWrapper.standard.set(user, forKey: "userID")
            KeychainWrapper.standard.set(token, forKey: "token")
            
            UserDefaults.standard.set(user, forKey: "userID")
            UserDefaults.standard.set(token, forKey: "token")
            os_log(.info, log: .network, "Login Success")
            DispatchQueue.main.async {
                self.loginEnded()
                self.performSegue(withIdentifier: "loggedIn", sender: Any?.self)
            }
        } else {
            DispatchQueue.main.async {
                self.loginEnded()
                os_log(.error, log: .network, "Login Failure")
                let alert = UIAlertController(title: "Error", message: err.errors?[0], preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true)
            }
        }
    }
    
    //MARK: Validation
    /// Check for Email
    /// Check for password
    func validate() -> Bool{
        if emailTextField.text == "" {
            SPAlert.present(message: "Email is empty", haptic: .error)
            return false
        }
        if passwordTextField.text == "" {
            SPAlert.present(message: "Password is empty", haptic: .error)
            return false
        }
        return true
    }
    
    /// Tap view to dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    //MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    /// `Unwind segue` back to  Login Screen
    @IBAction func unwindToLogin( _ seg: UIStoryboardSegue) {  }
    
}


//END
