//
//  DurationViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 20/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

protocol TimesDelegate : class {
    func returnTimes(times: [String])
    func returnDateAndTime(dates: [String], times: [String])
}

class DurationViewController: UIViewController {

    /// Outlets
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var toDate: UILabel!
    @IBOutlet weak var fromTime: UITextField!
    @IBOutlet weak var toTime: UITextField!
    
    
    /// Variables
    var booking = BookingModel()
    var editRentalModel : EditRentalModel?
    var dates = [String]()
    var times = [String]()
    var address = ""
    
    /// Selected `Featured` Trailer
    var selectedtrailer : String?
    
    let dateformatter = DateFormatter()
    
    weak var delegate: TimesDelegate?
    var presenter : UIViewController?
    
    var datePicker = UIDatePicker()
    var activeTextField : UITextField!
    
    
    /// Inital setup
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        dateformatter.timeStyle = .short
        bottomBar.makeCard()
        
        ///Dates
        dates = booking.dates!
        fromDate.text = dates[0]
        toDate.text = dates[1]
        
        ///Times
        if times.count > 0 {  fromTime.text = times[0]  }
        if times.count > 1 { toTime.text = times[1] }
        
        /// Corner radius
        nextButton.layer.cornerRadius = 8
        fromTime.layer.cornerRadius = 8
        toTime.layer.cornerRadius = 8
        
        ///Delegates
        fromTime.delegate = self
        toTime.delegate = self
        
        
        /// background color
        fromTime.backgroundColor = .secondarySystemFill
        toTime.backgroundColor = .secondarySystemFill
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !times.isEmpty {
            fromTime.text = times.first
            toTime.text = times.last
        }
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setupDatePicker(textField: UITextField, date : String?) {
        let now = Date()
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 216))
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 15
        datePicker.backgroundColor = .secondarySystemBackground
        
        datePicker.minimumDate = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: now)
        datePicker.maximumDate = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: now)
        
        if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels }
        
        if (textField == fromTime) && isToday() { datePicker.minimumDate = Date().addHours(n: 2) }

        if !validate() && textField == fromTime {
            let calendar = Calendar.current
            let date = calendar.date(byAdding: .hour, value: 2, to: now)
            datePicker.minimumDate = date
        }

        if let text = textField.text, !text.isEmpty {
            dateformatter.timeZone = .current
            if let date = dateformatter.date(from:text){
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            let finalDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())
            datePicker.date = finalDate ?? Date()
        }
    }
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: target, action: nil)
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: #selector(timeSelected))
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        toolBar.barTintColor = .secondarySystemBackground
        toolBar.sizeToFit()
        
        textField.inputView = datePicker
        textField.inputAccessoryView = toolBar
    }
     
    @objc func timeSelected() {
        activeTextField.text = dateformatter.string(from: datePicker.date)
        activeTextField.resignFirstResponder()
        if fromTime.text != "" && toTime.text != "" {
            times = [fromTime.text!, toTime.text!]
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        if presenter?.isKind(of: TrailerViewController.self) ?? false {
            if fromTime.text != "" && toTime.text != "" {
                times = [fromTime.text!, toTime.text!]
                delegate?.returnTimes(times: times)
                self.dismiss(animated: true, completion: nil)
           }
        }
        else if presenter != nil {
                self.performSegue(withIdentifier: "bookings", sender: Any?.self)
        }
        else {
            if fromTime.text != "" && toTime.text != "" {
                times = [fromTime.text!, toTime.text!]
                self.performSegue(withIdentifier: "listings", sender: Any?.self)
            }
        }
    }
    
    func validate()->Bool{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, YYYY"
        if let startDate = formatter.date(from: dates.first ?? ""){
            if startDate == Date.today {
                return false
            }
                return true
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TrailerViewController {
           booking.times = times
            vc.booking = booking
            vc.address = address
            if let name = self.selectedtrailer{
                vc.selectedtrailer = name
            }
        }
        if let vc = segue.destination as? UpcomingBookingTableViewController {
            times = [fromTime.text!, toTime.text!]
            vc.returnDateAndTime(dates: dates, times: times)
        }
    }
    
    func isToday()->Bool{
        let date = dates[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        if let sDate = formatter.date(from: date){
            let day = Calendar.current.component(.day, from: sDate)
            let month = Calendar.current.component(.month, from: sDate)
            
            let currentDay = Calendar.current.component(.day, from: Date())
            let currentMonth = Calendar.current.component(.month, from: Date())
            
            return (day == currentDay) && (month == currentMonth)
        }
        return false
    }



}

extension DurationViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        setupDatePicker(textField: textField, date : textField.text)
    }
}


