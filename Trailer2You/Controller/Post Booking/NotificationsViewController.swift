//
//  NotificationsViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 28/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import ProgressHUD

class NotificationsViewController: UITableViewController {
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var subHeader: UILabel!
    
    var reminders = [Reminder]()
    var invoices = [ReviewData]()
    var selectedBooking = ""
    var tapped = -1
    var reminderType = ReminderType.reminders
    
    var isRating : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        initialSetup()
        getReminders()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if reminderType == .all && self.reminders.count == 0{
            ProgressHUD.show("Loading...", icon: .cart, interaction: true)
        }
    }
    
    func initialSetup(){
        header.text = reminderType.title
        subHeader.text = reminderType.subTitle
        if reminderType == .reminders{
            refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refreshControl?.tintColor = .tertiaryLabel
            refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
            refreshControl?.beginRefreshing()
        } else {
            self.refreshControl = nil
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getReminders()
    }
    
    func getReminders() {
        ServiceController.shared.getReminders(reminderType) { (status, reminders, errors) in
            if status {
                self.reminders = reminders
                self.reminders.sort { (r1, r2) -> Bool in
                    let d1 = (r1.reminderText?.split(separator: " ")[0] ?? "")
                    let d2 = (r2.reminderText?.split(separator: " ")[0] ?? "")
                    
                    return Int(d1)! < Int(d2)!
                    
                }
                
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
            else {
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isRating ? 150 : 110
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellToReturn = UITableViewCell()
        if reminderType == .rating {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingcell") as! RatingCell
            let data = invoices[indexPath.row]
            cell.trailerName.text = data.trailer.name ?? ""
            cell.trailerImage.kf.setImage(with: URL(string: data.trailer.photos?.first?.data ?? ""))
            cell.trailerSubtitle.text = data.invoice.dateDetails
            cell.reviewButton.tag = indexPath.row
            cell.reviewButton.addTarget(self, action: #selector(rateTrailer(sender:)), for: .touchUpInside)
            
            cell.detailsButton.tag = indexPath.row
            cell.detailsButton.addTarget(self, action: #selector(viewBooking(sender:)), for: .touchUpInside)
            cellToReturn = cell
        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationTableViewCell
        let reminder = reminders[indexPath.row]
        cell.trailerName.text = reminder.rentedItems[0].itemName
        cell.trailerImage.kf.setImage(with: URL(string: reminder.rentedItems[0].itemPhoto?.data ?? ""))
        let days = (reminder.reminderText?.split(separator: " ")[0] ?? "")
        let days2 = (reminder.reminderText?.split(separator: " ")[1] ?? "")
        if reminder.isApproved == 1 {
            cell.daysLabel.text = days + " " + String(days2)
            cell.days = String(days)
            cell.statusLabel.text = reminder.reminderText?.components(separatedBy: " ").dropFirst(2).joined(separator: " ")
            cell.setStatus(status: TrailerRentalStatus(rawValue: reminder.reminderType ?? "ongoing") ?? .ongoing)
        }
            
        else if reminder.isApproved == 0 {
            cell.daysLabel.text = "Waiting"
            cell.statusLabel.text = "For Approval"
            cell.setStatus(status: .waiting)
        }
        else {
            cell.daysLabel.text = "Cancelled"
            cell.statusLabel.text = "Request"
            cell.setStatus(status: .denied)
        }
        
        cell.licenseeName.text = reminder.licenseeName
            cellToReturn = cell
    }
        return cellToReturn
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isRating ? invoices.count : reminders.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapped = indexPath.row
        selectedBooking = reminders[tapped].invoiceId ?? ""
        if (reminders[tapped].isTracking ?? false) {
            let actionSheet = UIAlertController(title: "What do you want to do?", message: "", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Track your trailer", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "tracking", sender: Any?.self)
            }))
            actionSheet.addAction(UIAlertAction(title: "View Booking", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "booking", sender: Any?.self)
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true)
        } else {
            self.performSegue(withIdentifier: "booking", sender: Any?.self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bookingVC = segue.destination as? UpcomingBookingTableViewController {
            if isRating {
                bookingVC.bookingID = selectedBooking
                bookingVC.trailer = InvoiceDisplayItem(name: invoices[tapped].trailer.name, photo: invoices[tapped].trailer.photos?.first, price: 0.0, units: 1)
                bookingVC.licenseeName = invoices[tapped].licensee.name ?? ""
            } else {
            bookingVC.bookingID = selectedBooking
            bookingVC.trailer = InvoiceDisplayItem(name: reminders[tapped].rentedItems[0].itemName, photo: reminders[tapped].rentedItems[0].itemPhoto, price: 0.0, units: 1)
            bookingVC.action = reminders[tapped].reminderType ?? ""
            bookingVC.status = reminders[tapped].status ?? ""
            bookingVC.isApproved = reminders[tapped].isApproved ?? 0
            bookingVC.licenseeName = reminders[tapped].licenseeName ?? ""
            bookingVC.upsells = reminders[tapped].rentedItems.dropFirst().map({ (item) -> InvoiceDisplayItem in
                return InvoiceDisplayItem(name: item.itemName, photo: item.itemPhoto, price: 0.0, units: 1)
            })
            }
        }
        if let trackingVC = segue.destination as? TrackingViewController {
            trackingVC.inVoiceID = selectedBooking
        }
        
        if let ratingVC = segue.destination as? RatingsViewController{
            ratingVC.invoiceId = sender as! String
            ratingVC.delegate = self
        }
    }
    
    @objc func rateTrailer(sender: UIButton){
        let trailer = invoices[sender.tag].invoice.id ?? ""
        performSegue(withIdentifier: "rating", sender: trailer)
    }
    
    @objc func viewBooking(sender: UIButton){
        let trailer = invoices[sender.tag].invoice.id
        tapped = sender.tag
        selectedBooking = trailer ?? ""
        performSegue(withIdentifier: "booking", sender: "")
    }
    
}

extension NotificationsViewController : SkipDelegate{
    func didSkip() {
        self.dismiss(animated: true, completion: nil)
    }
}
