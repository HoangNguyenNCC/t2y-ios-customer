//
//  EditProfileViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 06/05/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import Just
import SPAlert
import Kingfisher
import PDFKit
import ProgressHUD

protocol profileDelegate : class {
    func profileSaved(profile :User?)
}

class EditProfileViewController: UITableViewController {
    
    ///Outlets
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var mobile: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var verifyMobileButton: UIButton!
    @IBOutlet weak var verifyEmailButton: UIButton!
    @IBOutlet weak var verificationCell: UITableViewCell!
    
    
    /// variables
    var profileUser: User?
    var originalUser: User?
    var userID: String = ""
    weak var delegate : profileDelegate?
    
    var oldValue = ""
    var photoData : Data?
    var save = false
    var wasDLChanged = false
    var wasAddressChanged = false
    var wasPhotoChanged = false
    
    
    var datePicker = UIDatePicker()
    var toolbar = UIToolbar()
    var activeTextField = UITextField()
    let activity = UIActivityIndicatorView(style: .medium)
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = user
        overrideUserInterfaceStyle = .light
        
        (self.originalUser == nil) ? getDetails() : loadUserData(originalUser!)
        
        ///Delegates
        name.delegate = self
        email.delegate = self
        mobile.delegate = self
        dob.delegate = self
        
        /// Padding
        name.setPadding()
        email.setPadding()
        mobile.setPadding()
        dob.setPadding()
        
        ///Corner Radius
        changePasswordButton.layer.cornerRadius = 8
        verifyEmailButton.layer.cornerRadius = 8
        verifyMobileButton.layer.cornerRadius = 8
        
        dob.inputView = UIView()
        
        
        /// Toolbar + Buttons
        setupToolbar()
        saveButton.setupButton(isTapped: true, text: "Save")
        cancelButton.setupButton(isTapped: false, text: "Cancel")
    }
    
    /// Change Profile Image
    @IBAction func addImage(_ sender: Any) {
        presentActionSheet()
    }
    
    /// Verify Email ID
    @IBAction func verifyMobiletapped(_ sender: Any) {
        DispatchQueue.main.async(){
            self.performSegue(withIdentifier: "verifymobile", sender: Any?.self)
        }
    }
    
    /// Verify Mobile number
    @IBAction func veryifyEmailTapped(_ sender: Any) {
        verifyEmail()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let otp = segue.destination as? OTPViewController{
            otp.mobileNumber = (self.originalUser?.mobile ?? "")
            otp.country = countryConstant
            otp.resendTapped((Any).self)
        }
    }
    
    
    func getDLScan() {
        guard let url = URL(string: self.profileUser?.driverLicense?.scan?.data ?? "") else { return }
        Just.get(url) { (r) in
            if (r.response?.mimeType == "image/jpeg") {
                let pdf = PDFDocument()
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    let pdfPage = PDFPage(image: UIImage(data: r.content!)!)
                    pdf.insert(pdfPage!, at: 0)
                    self.profileUser?.driverLicense?.scan?.data = (pdf.dataRepresentation()?.base64EncodedString() ?? "")
                }
            }
            else {
                self.profileUser?.driverLicense?.scan?.data =  (r.content?.base64EncodedString())!
            }
        }
    }
    
    func verifyEmail(){
        ServiceController.shared.verifyEmail(to: originalUser?.email) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.emailSuccessAlert()
                } else {
                    let alertView = SPAlertView(title: "Error", message: "Please try again later", preset: .error)
                    alertView.present()
                }
            }
        }
    }
    
    func getDate(dateString: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.date(from: dateString) ?? Date()
        dateFormatter.dateFormat = "dd MMM YYYY"
        return dateFormatter.string(from: date)
    }
    
    func Diff(new: [String : String], original : [String : String]) -> [String : String] {
        var differences = [String : String]()
        for (key, value) in original {
            if key != "photo" {
                if  value != new[key] {
                    differences[key] = new[key]
                }
            }
        }
        return differences
    }
    
    func saveWillBegin() {
        saveButton.setTitle("Saving", for: .normal)
        saveButton.addSubview(activity)
        activity.center.x = (saveButton.titleLabel?.frame.minX ?? 20) - 40
        activity.center.y = saveButton.center.y
        activity.color = .white
        activity.startAnimating()
    }
    
    func saveSuccess() {
        activity.stopAnimating()
        activity.removeFromSuperview()
        saveButton.setTitle("Save", for: .normal)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        saveWillBegin()
        
        var licenseData : Data?
        
        var difference = Diff(new: (profileUser?.dictionaryRepresentation)!, original: (originalUser?.dictionaryRepresentation)!)
        
        if wasDLChanged {
            difference.merge(dict:  (profileUser?.driverLicense!.dictionaryRepresentation)! )
            licenseData = Data(base64Encoded: profileUser?.driverLicense?.scan?.data ?? "")
            wasDLChanged = false
        }
        
        if wasAddressChanged {
            difference.merge(dict: (profileUser?.address!.dictionaryRepresentation)!)
            wasAddressChanged = false
        }
        
        difference["reqBody[name]"] = name.text!
        
        if let mobile = difference["reqBody[mobile]"] {
            difference["reqBody[mobile]"] = mobile.replacingOccurrences(of: countryCodeConstant, with: "")
            difference["reqBody[country]"] =  countryConstant
        }
        
        
        ServiceController.shared.editProfiles(params : difference,photo : photoData,licenseData : licenseData) { (status,user,error) in
            DispatchQueue.main.async {
                if status {
                    SPAlert.present(title: "Profile Updated", preset: .done)
                    self.saveSuccess()
                    self.delegate?.profileSaved(profile: user)
                } else {
                    SPAlert.present(message: error, haptic: .error)
                    self.saveSuccess()
                    print(error)
                }
            }
        }
        
    }
    
    
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToEditProfile( _ seg: UIStoryboardSegue) {
    }
    
    func getDetails() {
        ServiceController.shared.getUser(withID: userID) { (status, user, error) in
            if status {
                self.loadUserData(user)
                self.delegate?.profileSaved(profile: user)
            }
            else {
                DispatchQueue.main.async {
                    SPAlert.present(message: (error.errors?[0])!, haptic: .error)
                }
            }
        }
    }
        
        func loadUserData(_ user : User){
            self.profileUser = user
            self.originalUser = user
            DispatchQueue.main.async {
                self.getDLScan()
                self.name.text = user.name
                self.email.text = user.email
                self.mobile.text = user.mobile
                self.dob.text = self.getDate(dateString: user.dob ?? "")
                if (user.isMobileVerified ?? true) {
                    self.verifyMobileButton.isHidden = true
                }
                if (user.isEmailVerified ?? true) {
                    self.verifyEmailButton.isHidden = true
                }
                
                if (user.isMobileVerified ?? true) && (user.isEmailVerified ?? true) {
                    self.verificationCell.isHidden = true
                }
                
                if self.wasPhotoChanged {
                    self.photo.kf.setImage(with: URL(string: user.photo?.data ?? ""), options: [.forceRefresh])
                    self.wasPhotoChanged = false
                }
                else {
                    self.photo.kf.setImage(with: URL(string: user.photo?.data ?? ""))
                }
                self.tableView.reloadData()
            }
        }
    
    //MARK:- TableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
            }
        }
        
        if indexPath.section == 1 {
            let addressVC : AddressViewController = UIStoryboard(storyboard: .main).instantiateViewController()
            addressVC.delegate = self
            addressVC.addressCore = (profileUser?.address)!
            self.present(addressVC, animated: true)
        }
        
        if indexPath.section == 2 {
            let licenseeVC : DLViewController = UIStoryboard(storyboard: .main).instantiateViewController()
            licenseeVC.delegate = self
            licenseeVC.license = profileUser?.driverLicense
            self.present(licenseeVC, animated: true)
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            return 150
        case IndexPath(row: 5, section: 0):
            return 80
        case IndexPath(row: 6, section: 0):
            return verifyHeight()
        default:
            return 60
        }
    }
    
    func verifyHeight()->CGFloat{
        if (originalUser?.isMobileVerified ?? false) && (originalUser?.isEmailVerified ?? false) {
            return CGFloat(0)
        } else {
            return CGFloat(80)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
}

//MARK: TextField
extension EditProfileViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        oldValue = textField.text ?? ""
        activeTextField = textField
        activeTextField.layer.cornerRadius = 8
        activeTextField.backgroundColor = .secondarySystemBackground
        textField.inputAccessoryView = toolbar
        
        if textField == dob {
            datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 216))
            if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = .wheels }
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            let date = formatter.date(from: textField.text ?? "") ?? Date()
            datePicker.setDate(date, animated: true)
            datePicker.datePickerMode = .date
            textField.inputView = datePicker
            textField.becomeFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if save {
            oldValue = ""
        }
        else {
            textField.text = oldValue
        }
        activeTextField.backgroundColor = .clear
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case name:
            email.becomeFirstResponder()
        case email:
            mobile.becomeFirstResponder()
        case mobile:
            dob.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    func setupToolbar() {
        toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.barTintColor = .systemGray3
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTappd(_:)))
        let spacer =  UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped(_:)))
        toolbar.items = [cancel,spacer,done]
        toolbar.sizeToFit()
    }
    
    @objc func doneTapped(_ sender: Any) {
        if activeTextField == dob {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM YYYY"
            dob.text = formatter.string(from: datePicker.date)
            formatter.dateFormat = "YYYY-MM-dd"
            profileUser?.dob = formatter.string(from: datePicker.date)
        }
        
        if activeTextField == name {
            profileUser?.name = name.text
        }
        
        if activeTextField == email {
            profileUser?.email = email.text
        }
        
        if activeTextField == mobile {
            profileUser?.mobile = mobile.text
        }
        save = true
        activeTextField.resignFirstResponder()
    }
    
    @objc func cancelTappd(_ sender: Any) {
        save = false
        activeTextField.resignFirstResponder()
    }
}


extension EditProfileViewController : addressDelegate, DLDelegate {
    func returnDLData(License: DriverLicense) {
        wasDLChanged = true
        profileUser?.driverLicense = License
    }
    
    func didEnterAddress(address: Address) {
        wasAddressChanged = true
        profileUser?.address = address.addressRequest
    }
}


//MARK: Image picker
extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.main.async {
            guard let image = info[.editedImage] as? UIImage else { return }
            self.photo.image = image
            self.wasPhotoChanged = true
            self.photoData = image.pngData()
            self.dismiss(animated: true)
        }
    }
    
    func presentActionSheet(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        let action = UIAlertController(title: "", message: "Pick an image", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (a) in
            picker.sourceType = .camera
            self.present(picker, animated: true)
        })
        let photo = UIAlertAction(title: "Photos", style: .default, handler: { (a) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        })
        
        let cancel = UIAlertAction(title: "Canel", style: .cancel, handler: nil)
        
        action.addAction(camera)
        action.addAction(photo)
        action.addAction(cancel)
        self.present(action, animated: true)
    }
    
}

extension EditProfileViewController {
    //MARK: - ALERT function success mail verify
    func emailSuccessAlert() {
        UIDevice.validVibrate()
        let alert = UIAlertController(title: "Verification email sent 📧", message: "Please check your mail" , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Mail", style: .default) { (_) -> Void in
            let settingsUrl =  URL(string: "message://")
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        })
        alert.addAction(UIAlertAction(title: "dismiss", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
