//
//  PaymentViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 08/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import SPAlert
import Stripe

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var expiryField: UITextField!
    @IBOutlet weak var cvvField: UITextField!
    @IBOutlet weak var payButton: UIButton!
    
    var payment : SetupPaymentResponse?
    
    var invoice = InvoiceGenerated()
    var datePickerView = MonthYearPickerView()
    var expiryDate = ""
    
    var clientSecret = ""
    var customerID = ""
    
    var cardLength = 16
    var cvvLength = 3
    
    override func viewDidLoad() {
        
        self.clientSecret = payment?.stripeClientSecret ?? ""
        
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        expiryField.delegate = self
        expiryField.inputView = UIView()
        cardNumberField.delegate = self
        cvvField.delegate = self
        Payments.delegate = self
        //  setupPayment()
        cardNumberField.keyboardType = .numberPad
        cvvField.keyboardType = .numberPad
        cardNumberField.setPadding()
        datePickerView.onDateSelected = { (month: Int, year: Int) in
            let yearString = String(describing: year).suffix(2)
            let monthString = String(format: "%02d", month)
            let date = "\(monthString)/\(yearString)"
            self.expiryDate = date
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        payButton.layer.cornerRadius = payButton.frame.height/2
        nameField.setPadding()
        expiryField.setPadding()
        cvvField.setPadding()
        if cardNumberField.text == "" {
            self.cardNumberField.setPadding()
        }
        nameField.layer.cornerRadius = 8
        cardNumberField.layer.cornerRadius = 8
        expiryField.layer.cornerRadius = 8
        cvvField.layer.cornerRadius = 8
    }
    
    @objc func cancelPressed() {
        expiryField.resignFirstResponder()
    }
    
    @objc func donePressed() {
        expiryField.resignFirstResponder()
        expiryField.text = expiryDate
    }
    
    @IBAction func payBttnTapped(_ sender: Any) {
        let cardParams = STPCardParams()
        cardParams.number = cardNumberField.text
        cardParams.expYear = UInt(expiryDate.components(separatedBy: "/")[1]) ?? 0
        cardParams.expMonth = UInt(expiryDate.components(separatedBy: "/")[0]) ?? 0
        cardParams.cvc = cvvField.text
        cardParams.name = nameField.text
        
        let paymentMethod = STPPaymentMethodCardParams(cardSourceParams: cardParams)
        
        let paymentMethodParams = STPPaymentMethodParams(card: paymentMethod, billingDetails: STPPaymentMethodBillingDetails(), metadata: nil)
        
        let setupIntentParams = STPSetupIntentConfirmParams(clientSecret: clientSecret)
        
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        
        paymentIntentParams.paymentMethodParams = paymentMethodParams
        
        setupIntentParams.paymentMethodParams = paymentMethodParams
        
        let paymentHandler = STPPaymentHandler.shared()

        paymentHandler.confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { status, setupIntent, error in
            print("payment status is",status.rawValue)
            switch (status) {
            case .failed:
                print("failed")
                SPAlert.present(message: error?.localizedDescription ?? "", haptic: .error)
                break
            case .canceled:
                print("cancelled")
                SPAlert.present(message: error?.localizedDescription ?? "", haptic: .error)
                break
            case .succeeded:
                print("Success")
                print(self.customerID)
                DispatchQueue.main.async {
                    SPAlert.present(title: "Success", message: "Thank you!", preset: .heart)
                    self.segueBack()
                }
                break
            @unknown default:
                fatalError()
                break
            }
        }
    }
    

    
    func segueBack() {
        self.performSegue(withIdentifier: "unwindToNotifications", sender: Any?.self)
    }
    
    func checkCard(text: String) {
        if case .identified(let card) = CardState(fromPrefix: text) {
            switch card {
            case .visa : cardNumberField.addCardIcon(card: "visa")
            case .amex : cardNumberField.addCardIcon(card: "amex")
            case .masterCard : cardNumberField.addCardIcon(card: "mastercard")
            case .diners : cardNumberField.addCardIcon(card: "diners")
            case .jcb : cardNumberField.addCardIcon(card: "jcb")
            case .discover : cardNumberField.addCardIcon(card: "discover")
            }
            cvvLength = card.cvvLength
            cardLength = card.maxLength
        }
    }
    
    func validate()->Bool{
        if cardNumberField.text?.isEmpty ?? false {
            
            return false
        }
        
        if expiryField.text?.isEmpty ?? false {
            
            return false
        }
        
        if cvvField.text?.isEmpty ?? false {
            
            return false
        }
        
        if nameField.text?.isEmpty ?? false {
            
            return false
        }
        
        return true
    }
    
}





extension PaymentViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == expiryField {
            textField.inputView = datePickerView
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
            let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: #selector(donePressed))
            toolBar.setItems([cancelBarButton, flexibleSpace, doneBarButton], animated: true)
            textField.inputAccessoryView = toolBar
            textField.becomeFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cardNumberField {
            if textField.text == "" {
                self.cardNumberField.setPadding()
            }
            else if textField.text!.count >= 1 {
                checkCard(text: textField.text ?? "")
            }
            let maxLength = cardLength
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        if textField == cvvField {
            let maxLength = cvvLength
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    
}


extension PaymentViewController : PaymentDelegate {
    func paymentComplete(submissionID: String) {
        print("Success : " + submissionID)
    }
    
    func paymentFailed(errorCode: String) {
        print("Failed : " + errorCode)
    }
}

extension PaymentViewController : STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}


public extension String {
    var length: Int {
        get {
            return self.count
        }
    }
    
    func substring(to : Int) -> String {
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[...toIndex])
    }
    
    func substring(from : Int) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[fromIndex...])
    }
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        let indexRange = Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex))
        return String(self[indexRange])
    }
    
    func character(_ at: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: at)]
    }
}
