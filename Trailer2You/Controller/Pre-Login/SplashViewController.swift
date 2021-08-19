//
//  SplashViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 28/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

/// Viewcontroller for `Splash Screen`
class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    
    /// Check if user is logged in or not
    /// Logged in : Go to `Tab bar`
    /// Logged out : ' Go to `Login ViewController`
    override func viewDidAppear(_ animated: Bool) {
        print("RATINGG: ",UserDefaults.standard.value(forKey: "rate"))
        if let retrievedToken = KeychainWrapper.standard.string(forKey: "token"), let retrievedUser = KeychainWrapper.standard.string(forKey: "userID") {
            user = retrievedUser
            token = retrievedToken
            print(token)
            login()
        }
        else {
            self.performSegue(withIdentifier: "noLogin", sender: Any?.self)
        }
    }
    
    func login(){
        let email = KeychainWrapper.standard.string(forKey: "email")
        let password = KeychainWrapper.standard.string(forKey: "password")
        if let email = email, let pass = password {
            print(email,pass)
            ServiceController.shared.login(withEmail: email, withPassword: pass) { (success, response, error) in
                if success {
                    token = response.dataObj?.token ?? ""
                    user = response.dataObj?.userObj?._id ?? ""
                    
                    KeychainWrapper.standard.set(user, forKey: "userId")
                    KeychainWrapper.standard.set(token, forKey: "token")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "preLogin", sender: Any?.self)
                    }
                } else {
                    print("NO LOGIN")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "noLogin", sender: Any?.self)
                    }
                }
            }
            
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "noLogin", sender: Any?.self)
            }
        }
        
    }
    
    
    /// `Unwind segue` back to  Splash screen
    @IBAction func unwindToSplash( _ seg: UIStoryboardSegue) {
    }
    
}

//END
