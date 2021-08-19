//
//  OTPViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 20/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import OTPFieldView
import SPAlert

class OTPViewController: UIViewController {
    
    @IBOutlet weak var OTPView: OTPFieldView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    var mobileNumber = String()
    var country = String()
    var otp = String()
    
    var login : Bool = false
    
    override func viewDidLoad() {
        self.mobileNumber = self.mobileNumber.replacingOccurrences(of: countryCodeConstant, with: "")
        self.mobileNumber = self.mobileNumber.replacingOccurrences(of:"+91", with: "")
        print("mobile:",mobileNumber)
        print("country:",country)
        super.viewDidLoad()
        confirmButton.layer.cornerRadius = confirmButton.frame.height/2
        setup()
        overrideUserInterfaceStyle = .light
        skipButton.isHidden = !login
        
        if !login {
            resend()
        }
    }
    
    func setup() {
        self.OTPView.fieldsCount = 4
        self.OTPView.displayType = .roundedCorner
        self.OTPView.fieldSize = 40
        self.OTPView.separatorSpace = 8
        self.OTPView.shouldAllowIntermediateEditing = false
        self.OTPView.requireCursor = false
        self.OTPView.fieldBorderWidth = 0
        self.OTPView.defaultBackgroundColor = .secondarySystemBackground
        self.OTPView.filledBackgroundColor = .secondarySystemBackground
        
        self.OTPView.otpInputType = .numeric
        self.OTPView.fieldFont = UIFont(name: "AvenirNext-Medium", size: 15)!
        self.OTPView.delegate = self
        self.OTPView.initializeUI()
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        ServiceController.shared.verifyOTP(to: mobileNumber, in: country, otp: otp) { (status, error) in
            DispatchQueue.main.async {
                status ? self.performSegue(withIdentifier: "success", sender: Any?.self) : SPAlert.present(title: error.errors?.first ?? "Error", preset: .error)
            }
        }
    }
    
    @IBAction func resendTapped(_ sender: Any) {
     resend()
    }
    
    func resend(){
        ServiceController.shared.sendOTP(to: mobileNumber, in: country) { (status, error) in
            DispatchQueue.main.async {
                if status && self.login{
                    SPAlert.present(title: "Success", preset: .done)
                   }
            }
        }
    }
    
    
    @IBAction func skipTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToLogin", sender: Any?.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SuccessViewController{
            vc.login = self.login
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension OTPViewController : OTPFieldViewDelegate {
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp: String) {
        self.otp = otp
    }
    
    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        return false
    }
}
