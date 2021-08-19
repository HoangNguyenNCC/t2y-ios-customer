//
//  DLViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 03/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit
import VisionKit
import SafariServices

// MARK: - Protocols
protocol DLDelegate : class {
    func returnDLData(License: DriverLicense)
}

class DLViewController : UIViewController {
    
    // MARK: - Declarations
    @IBOutlet weak var DLView: UIView!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expiryTextField: UITextField!
    @IBOutlet weak var addScanButton: UIButton!
    @IBOutlet weak var stateTextField: UITextField!
    
    weak var delegate: DLDelegate?
    var datePickerView : UIDatePicker = UIDatePicker()
    var expiryDate = ""
    
    var licenseScanData : String?
    
    let thePicker = UIPickerView()
    let states = ["New South Wales", "Victoria", "Queensland", "Western Australia", "South Australia", "Tasmania"]
    
    var frame = CGRect()
    
    var license: DriverLicense?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        frame = self.view.frame
        
        expiryTextField.delegate = self
        stateTextField.delegate = self
        thePicker.delegate = self
        thePicker.dataSource = self
        
        stateTextField.inputView = UIView()
        expiryTextField.inputView = UIView()
        
        expiryTextField.inputView = datePickerView
        datePickerView.minimumDate = Date()
        datePickerView.date = Date().addYears(n: +1)
        if #available(iOS 13.4, *) { datePickerView.preferredDatePickerStyle = .wheels }
        
        addScanButton.setTitleColor(.primary, for: .normal)
        
        setupDatePicker()
        
        if let license = license {
            cardNumberTextField.text = license.card
            expiryTextField.text = license.expiry
            stateTextField.text = license.state
            self.licenseScanData = license.scan?.data
            addScanButton.setTitle("View Scan", for: .normal)
            
            if let expiry = license.expiry {
                expiryTextField.text = (expiry.count > 12 ? String(expiry.prefix(10)) : expiry) //TOOD
            }
        }
        
        self.isModalInPresentation = true
    }
    
    func setupDatePicker(){
        datePickerView.datePickerMode = .date
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: #selector(donePressed))
        toolBar.setItems([cancelBarButton, flexibleSpace, doneBarButton], animated: true)
        expiryTextField.inputAccessoryView = toolBar
    }
    
    @objc func cancelPressed() {
        expiryTextField.resignFirstResponder()
    }
    
    @objc
    func donePressed() {
        expiryTextField.resignFirstResponder()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        expiryTextField.text = formatter.string(from: datePickerView.date)
      //formatter.dateFormat =  "yyyy-MM-dd"
        formatter.dateFormat =  "yyyy-MM"
        self.expiryDate = formatter.string(from: datePickerView.date)
    }
    
    // MARK: - Buttons
    @IBAction func addScanTapped(_ sender: Any) {
        let action = UIAlertController(title: "", message: "Select Scan", preferredStyle: .actionSheet)
        if licenseScanData != nil {
            action.addAction(UIAlertAction(title: "View Scan", style: .default, handler: { (a) in
                self.performSegue(withIdentifier: "scan", sender: Any?.self)
            }))
        }
        action.addAction(UIAlertAction(title: "Click a scan", style: .default, handler: { (a) in
            let documentCameraViewController = VNDocumentCameraViewController()
            documentCameraViewController.delegate = self
            self.present(documentCameraViewController, animated: true)
        }))
        action.addAction(UIAlertAction(title: "Pick a scan", style: .default, handler: { (a) in
            let picker = UIDocumentPickerViewController(documentTypes: ["public.composite-content"], in: .import)
            picker.delegate = self
            picker.allowsMultipleSelection = false
            self.present(picker, animated: true, completion: nil)
        }))
        action.addAction(UIAlertAction(title: "Canel", style: .cancel, handler: nil))
        self.present(action, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pdfVC = segue.destination as? PDFViewController {
            pdfVC.pdfData = Data(base64Encoded: licenseScanData ?? "") ?? Data()
        }
    }
    
    @IBAction func addLicenseTapped(_ sender: Any) {
        if let scan = licenseScanData {
            let license = DriverLicense(verified: nil, card: cardNumberTextField.text!, accepted: nil, expiry: expiryDate, state: stateTextField.text!, scan: Photo(contentType: "application/pdf", data: scan))
            delegate?.returnDLData(License: license)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Layouts
    
    override func viewDidLayoutSubviews() {
        DLView.layer.cornerRadius = 8
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func selectState() {
        stateTextField.resignFirstResponder()
        stateTextField.text = states[thePicker.selectedRow(inComponent: 0)]
    }
}

func formattedDate(_ date: String)->String{
    if date.count == 7{
        let split = date.split(separator: "-")
        let year = String(split[0]).substring(from: 2)
        let Finaldate = String(split[1]) + "/" + year
        return Finaldate
    } else {
        return date
    }
}


extension DLViewController : UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let url = urls[0]
        let data = try! Data(contentsOf: url)
        licenseScanData = data.base64EncodedString()
        addScanButton.setTitle("View Scan", for: .normal)
    }
}

extension DLViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row]
    }
}
