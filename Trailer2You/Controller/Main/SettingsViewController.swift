//
//  SettingsViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 06/05/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var userData : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        logoutButton.layer.cornerRadius = logoutButton.frame.height/2
        
        overrideUserInterfaceStyle = .light
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getUser()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "token")
        
        KeychainWrapper.standard.removeObject(forKey: "email")
        KeychainWrapper.standard.removeObject(forKey: "password")
        KeychainWrapper.standard.removeObject(forKey: "token")
        KeychainWrapper.standard.removeObject(forKey: "userID")

        
        self.performSegue(withIdentifier: "logout", sender: Any?.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileVC = segue.destination as? EditProfileViewController{
            profileVC.delegate = self
            profileVC.profileUser = self.userData
            profileVC.originalUser = self.userData
        }
        if let reminderVC = segue.destination as? NotificationsViewController{
            reminderVC.reminderType = .all
        }
    }
    
    func getUser(){
        ServiceController.shared.getUser(withID: user) { (success, userData, _) in
            if success { self.userData = userData }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsTableViewCell
        if indexPath.row == 0 {
            cell.iconView.image = UIImage(named: "Profile")
            cell.title.text = "Profile"
            cell.subtitle.text = "Settings regarding your details"
        }
        
        if indexPath.row == 1 {
            cell.iconView.image = UIImage(named: "Notification")
            cell.title.text = "Rental History"
            cell.subtitle.text = "All your trailers ever booked!"
        }
        
        if indexPath.row == 2 {
            cell.iconView.image = UIImage(named: "Info")
            cell.title.text = "About us"
            cell.subtitle.text = "Some information about us"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "profile", sender: Any?.self)
        }
        if indexPath.row == 1{
            self.performSegue(withIdentifier: "history", sender: Any?.self)
        }
        if indexPath.row == 2{
            self.performSegue(withIdentifier: "aboutus", sender: Any?.self)
        }
    }
}


extension SettingsViewController : profileDelegate {
    func profileSaved(profile: User?) {
        self.userData = profile
    }
}
