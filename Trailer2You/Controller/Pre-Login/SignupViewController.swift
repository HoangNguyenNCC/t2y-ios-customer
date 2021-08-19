//
//  SignupViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 03/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import SPAlert
import SafariServices
import PhoneNumberKit

class SignupViewController: UIViewController, SFSafariViewControllerDelegate {
    
    
    // MARK: - Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var DLTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var mobileTextField: PhoneNumberTextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var privacyLabel: UILabel!
    
    //MARK: - Variables
    var datePickerView : UIDatePicker = UIDatePicker()
    var addressCore: AddressRequest?
    var license: DriverLicense?
    let activity = UIActivityIndicatorView(style: .medium)
    var imagePicker = UIImagePickerController()
    var profileData : Data?
    var licenseData : Data?
    var DOB = Date()
    
    
    //MARK: ----- Initial Setup -----
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        PhoneNumberKit.CountryCodePicker.commonCountryCodes = ["IN", "AU"]
        
        //set delegates
        DLTextField.delegate = self
        DLTextField.inputView = UIView()
        dobTextField.delegate = self
        dobTextField.inputView = datePickerView
        addressTextField.delegate = self
        addressTextField.inputView = UIView()
        
        datePickerView.maximumDate = Date().addYears(n: -16) /// 16 years or older for DL
        datePickerView.date = Date().addYears(n: -20)
        if #available(iOS 13.4, *) { datePickerView.preferredDatePickerStyle = .wheels }
        setupPrivacyPoliyLabel()
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        profileImage.layer.cornerRadius = 8
    }
    
    // MARK: - Layouts
    override func viewDidLayoutSubviews() {
        
        /// TextField icons
        fullNameTextField.addIcon(iconName: "person.circle.fill")
        addressTextField.addIcon(iconName: "mappin.circle.fill")
        dobTextField.addIcon(iconName: "calendar.circle.fill")
        DLTextField.addIcon(iconName: "doc.on.clipboard.fill")
        emailTextField.addIcon(iconName: "envelope.circle.fill")
        passwordTextField.addIcon(iconName: "lock.fill")
        confirmPasswordTextField.addIcon(iconName: "lock.fill")
        
        
        /// Mobile textfield setup
        mobileTextField.withFlag = true
        mobileTextField.withExamplePlaceholder = true
        mobileTextField.maxDigits = (mobileTextField.currentRegion == "IN") ? 10 : 9
        mobileTextField.withDefaultPickerUI = true
        
        
        /// Corner radii
        fullNameTextField.layer.cornerRadius = 8
        addressTextField.layer.cornerRadius = 8
        dobTextField.layer.cornerRadius = 8
        DLTextField.layer.cornerRadius = 8
        emailTextField.layer.cornerRadius = 8
        passwordTextField.layer.cornerRadius = 8
        confirmPasswordTextField.layer.cornerRadius = 8
        mobileTextField.layer.cornerRadius = 8
        signupButton.layer.cornerRadius = signupButton.frame.height/2
    }
    
    //MARK: --- Privacy Policy Setup ---
    
    
    @IBAction func privacyTapped(_ sender: Any) {
        if let url = URL(string: privacyPolicyURL) {
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
        } else {
            SPAlert.present(message: "Contact Admin", haptic: .error)
        }
    }
    
    func setupPrivacyPoliyLabel(){
        let attributesForUnderLine: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "AvenirNext-Medium", size: 12),
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        let attributesForNormalText: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "AvenirNext-Medium", size: 12),
            .foregroundColor: UIColor.black]
        
        let textToSet = "By creating an account I agree toTrailer2You's Privacy Policy"
        let rangeOfUnderLine = (textToSet as NSString).range(of: "Privacy Policy")
        let rangeOfNormalText = (textToSet as NSString).range(of: "By creating an account I agree toTrailer2You's")
        
        let attributedText = NSMutableAttributedString(string: textToSet)
        attributedText.addAttributes(attributesForUnderLine, range: rangeOfUnderLine)
        attributedText.addAttributes(attributesForNormalText, range: rangeOfNormalText)
        privacyLabel.attributedText = attributedText
    }
    
    //MARK: ----- Signup Flow -----
    
    ///BEGIN
    func signupWillBegin() {
        signupButton.setTitle("Signing up", for: .normal)
        signupButton.addSubview(activity)
        activity.center.x = (signupButton.titleLabel?.frame.minX ?? 20) - 40
        activity.center.y = signupButton.center.y
        activity.color = .white
        activity.startAnimating()
    }
    
    ///REQUESTS
    func signup() {
        let wholeNumber = mobileTextField?.text?.replacingOccurrences(of: " ", with: "").dropFirst(3)
        let mobileNumber = String(wholeNumber ?? "")
        
        ServiceController.shared.signUp(photo: profileData, email: emailTextField.text, password: passwordTextField.text!, name: fullNameTextField.text!, mobile: mobileNumber, address: addressCore, dob: DOB.getDOB(), driversLicense: license, licenseData: self.licenseData, completion: handleSignup(status:error:))
    }
    
    /// Handle Request
    func handleSignup(status:Bool,error:String?){
        DispatchQueue.main.async {
            self.signupEnded()
            if status {
                self.saveData()
                self.performSegue(withIdentifier: "verify", sender: Any?.self)
            }
            else {
                SPAlert.present(message: error ?? "Error", haptic: .error)
            }
        }
    }
    
    ///END
    func signupEnded() {
        activity.stopAnimating()
        activity.removeFromSuperview()
        signupButton.setTitle("Signup", for: .normal)
    }
    
    func saveData(){
        UserDefaults.standard.set(mobileTextField.text, forKey: Keys.mobile)
        UserDefaults.standard.set(self.addressCore?.country, forKey: Keys.country)
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        if isValidated() {
            signupWillBegin()
            signup()
        }
    }
    
    //MARK: Validation of all fields
    func isValidated() -> Bool {
        
        if fullNameTextField.text == "" {
            SPAlert.present(message: "Name can't be empty", haptic: .error)
            return false
        }
        if profileData == nil {
            SPAlert.present(message: "Add a profile photo", haptic: .error)
            return false
        }
        if emailTextField.text == "" {
            SPAlert.present(message: "Email is empty", haptic: .error)
            return false
        }
        if mobileTextField.text == "" {
            SPAlert.present(message: "Enter your mobile number", haptic: .error)
            return false
        }
        if addressTextField.text == "" {
            SPAlert.present(message: "Add your address", haptic: .error)
            return false
        }
        if DLTextField.text == "" {
            SPAlert.present(message: "Add your license details", haptic: .error)
            return false
        }
        if !mobileTextField.isValidNumber {
            SPAlert.present(message: "Mobile Number is invalid", haptic: .error)
            return false
        }
        if passwordTextField.text == "" {
            SPAlert.present(message: "Password should contain 1 Capital Letter, 1 small letter, 1 digit and 1 special character", haptic: .error)
            return false
        }
        
        let passwordRegex = "^(?=.*[A-Z]+)(?=.*[!@#$&*]+)(?=.*[0-9]+)(?=.*[a-z]+).{8,20}$"
        if NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: passwordTextField.text) == false{
            SPAlert.present(message: "Password should contain 1 Capital Letter, 1 small letter, 1 digit and 1 special character", haptic: .error)
            return false
        }
        
        if passwordTextField.text?.count ?? 0 < 8 {
            SPAlert.present(message: "Password length should be more than 8 characters", haptic: .error)
            return false
        }
        
        if passwordTextField.text != confirmPasswordTextField.text {
            SPAlert.present(message: "Password and confirm password don't match", haptic: .error)
            return false
        }
        
        if dobTextField.text == "" {
            SPAlert.present(message: "Date of Birth is empty", haptic: .error)
            return false
        }
        
        if license?.card == "" {
            SPAlert.present(message: "Licensee card number is empty", haptic: .error)
            return false
        }
        
        if license?.state == "" {
            SPAlert.present(message: "Licensee State is empty", haptic: .error)
            return false
        }
        
        if license?.expiry == "" {
            SPAlert.present(message: "Licensee expiry date is empty", haptic: .error)
            return false
        }
        
        return true
    }
    
    
    
    ///Back to home
    @IBAction func loginTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelPressed() {
        dobTextField.resignFirstResponder()
    }
    
    @objc
    func donePressed() {
        dobTextField.resignFirstResponder()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        dobTextField.text = formatter.string(from: datePickerView.date)
        self.DOB = datePickerView.date
    }
    
    //MARK: Photo ActionSheet
    @IBAction func importPicture(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        let action = UIAlertController(title: "", message: "Pick an image", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (a) in
            picker.sourceType = .camera
            self.present(picker, animated: true)
        })
        cameraAction.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        action.addAction(cameraAction)
        action.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (a) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        }))
        action.addAction(UIAlertAction(title: "Canel", style: .cancel, handler: nil))
        self.present(action, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let addressVC = segue.destination as? AddressViewController {
            addressVC.delegate = self
        }
        
        if let LicenseVC = segue.destination as? DLViewController {
            LicenseVC.delegate = self
            if let data = license{
                LicenseVC.license = data
            }
        }
        
        if let OTPVC = segue.destination as? OTPViewController {
            let mobileNumber = String(mobileTextField?.text?.replacingOccurrences(of: " ", with: "") ?? "")
            OTPVC.mobileNumber = mobileNumber
            OTPVC.country = addressCore?.country ?? ""
            OTPVC.login = true
        }
    }
    
    
}

//MARK: ImagePickerController Delegate Methods
extension SignupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.main.async {
            guard let image = info[.editedImage] as? UIImage else { return }
            self.profileImage.image = image
            self.profileData = image.pngData()
            self.dismiss(animated: true)
        }
    }
}




