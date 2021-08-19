//
//  ConfirmationViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 26/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import SPAlert

class ConfirmationViewController: UITableViewController {
    
    var displayItems = [InvoiceDisplayItem]()
    var trailer = InvoiceDisplayItem()
    var upsells = [InvoiceDisplayItem]()
    var invoice = Invoice()
    var invoiceResponse = InvoiceGenerated()
    var damageCharges = String()
    var isDLRAdded = true
    var doChargeDlr = true
    var totalCost = 0.0
    var taxes = 0.0
    var damage = 0.0
    var booking = BookingModel()
    
    var payment : SetupPaymentResponse?
    
    var reschedule : RescheduleResponse?
    var charges : ChargesResponseModel?
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if trailer.name == nil { trailer = displayItems.first ?? InvoiceDisplayItem() }
        if reschedule == nil{
            upsells = Array(displayItems.dropFirst())
        }
        overrideUserInterfaceStyle = .light
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        confirmButton.layer.cornerRadius = confirmButton.frame.height/2
        
        
        totalCost = charges?.trailerCharges?.rentalCharges ?? 0.0
        
        taxes = charges?.totalTaxes() ?? 0.0
        
        damage = charges?.totalDlr() ?? 0.0
        
        doChargeDlr = (reschedule == nil) ? true :reschedule?.booking?.doChargeDLR ?? false
        
        
    }
    
    func bookTrailer() -> Payment {
        let start = (invoice.rentalPeriod?.start!) ?? ""
        let end = invoice.rentalPeriod!.end
        let location = invoice.dropOffLocation!
        let upsell = upsells.map { upsellObject(id: $0.id ?? "", quantity: $0.units ?? 1) }
        let payment = Payment(trailerId: booking.id ?? "", upsellItems: upsell, startDate:start, endDate: end ?? "", customerId: user, isPickup: invoice.isPickup ?? false, customerLocation: location, doChargeDLR: isDLRAdded)
        print(payment)
        return payment
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 2: return 1
        case 3: return upsells.count + 4
        default:
            return 0
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0: return setupSection0(indexPath: indexPath)
        case 1: return setupSection1(indexPath: indexPath)
        case 2: return setupSection2(indexPath: indexPath)
        case 3: return setupSection3(indexPath: indexPath)
            
        default:
            return UITableViewCell()
        }
        
    }
    
    func dateSplit() -> [(String, String)]{
        let dateFormatter = DateFormatter()
        
        print("rescheduleStaus:",reschedule)
        
        dateFormatter.dateFormat = (self.reschedule == nil) ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        let starting : String? = (self.reschedule == nil) ? invoice.rentalPeriod?.start : reschedule?.booking?.startDate
        
        let ending : String? = (self.reschedule == nil) ? invoice.rentalPeriod?.end : reschedule?.booking?.endDate
        
        let start = dateFormatter.date(from: starting  ?? "")
        let end = dateFormatter.date(from: ending ?? "")
        
        dateFormatter.dateFormat = "dd MMM"
        let startDate = dateFormatter.string(from: start!)
        let endDate = dateFormatter.string(from: end!)
        
        dateFormatter.timeStyle = .short
        let startTime = dateFormatter.string(from: start!)
        let endTime = dateFormatter.string(from: end!)
        
        print((startDate, startTime),(endDate, endTime))
        
        return [(startDate, startTime),(endDate, endTime)]
        
    }
    
    func FinalDateAndTime() -> [String] {
        let d1 = dateSplit()[0].0
        let t1 = dateSplit()[0].1
        let d2 = dateSplit()[1].0
        let t2 = dateSplit()[1].1
        
        return gmtDateAndTime(dates: [d1,d2], times: [t1,t2], dateformat: "dd MMM", timeformat: nil, returnDateFormat: "dd MMM", returnTimeFormat: "hh:mm a", convertToGmt: false)
    }
    
    //MARK:- Cells
    func setupSection0(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "confirmTrailerCell", for: indexPath) as! ConfirmationTrailerTableViewCell
        cell.trailerImage.kf.setImage(with: URL(string: trailer.photo?.data ?? ""))
        cell.trailerName.text = trailer.name
        return cell
    }
    
    func setupSection1(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "confirmBookingCell", for: indexPath) as! ConfirmationBookingTableViewCell
        
        cell.fromDate.text = FinalDateAndTime()[2]
        cell.fromTime.text = FinalDateAndTime()[0]
        cell.toDate.text = FinalDateAndTime()[3]
        cell.toTime.text = FinalDateAndTime()[1]
        
        return cell
    }
    
    func setupSection2(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "confirmLocationCell", for: indexPath) as! ConfirmationLocationTableViewCell
        cell.location.text =  (self.reschedule == nil) ? invoice.dropOffLocation?.text : reschedule?.booking?.customerLocation?.text
        return cell
    }
    
    func setupSection3(indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        if row == 0 {
            return setupItemRow(withitem: trailer.name ?? "Trailer", andPrice: charges?.trailerCharges?.rentalCharges ?? 0)
        }
        if row == upsells.count + 1 {
            return setupDamageRow(withDamageDesc: "Damage waiver covers any and all damage to the trailer. Waiving it might result in excess charges if the trailer is damaged.", andPrice: damage)
        }
        if row == upsells.count + 2 {
            return setupItemRow(withitem: "Taxes and VAT", andPrice: taxes)
        }
        if row == upsells.count + 3 {
            if isDLRAdded == false {
                return setupItemRow(withitem: "Grand Total", andPrice: taxes+totalCost)
            }
            else {
                return setupItemRow(withitem: "Grand Total", andPrice: self.charges?.totalPayableAmount ?? 0.0)
            }
        }
        else {
            var upsell = upsells[indexPath.row - 1]
            upsell.price = charges?.upsellBaseCharges()[upsell.id ?? ""]
            return setupUpsellRow(withPhoto: upsell.photo?.data ?? "", name: upsell.name ?? "", price: upsell.price ?? 0, quantity: upsell.units ?? 1)
        }
    }
    
    func setupItemRow(withitem name: String, andPrice price: Double) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "confirmItemCell") as! ConfirmationItemTableViewCell
        cell.itemName.text = name
        cell.itemPrice.text = "\(price.truncate(places: 2)) AUD"
        return cell
    }
    
    func setupDamageRow(withDamageDesc desc: String, andPrice price: Double) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "confirmDamageCell") as! ConfirmationDamageTableViewCell
        cell.DLRText.text = desc
        print("12AB,",isDLRAdded,doChargeDlr)
        cell.DLRPrice.text = "\(price.truncate(places: 2)) AUD"
        if isDLRAdded && doChargeDlr {
            cell.setDLR()
        }
        else {
            cell.removeDLR(reschedule != nil)
        }
        return cell
    }
    
    func setupUpsellRow(withPhoto url: String, name: String, price: Double, quantity: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "confirmUpsellCell") as! ConfirmationUpsellTableViewCell
        cell.upsellImage.kf.setImage(with: URL(string: url))
        if quantity > 1 {
            cell.upsellName.text = "\(quantity) x \(name)"
        }
        else {
            cell.upsellName.text = name
        }
        cell.upsellPrice.text = "\(price.truncate(places: 2)) AUD"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == upsells.count + 1 {
            let cell = tableView.cellForRow(at: indexPath) as! ConfirmationDamageTableViewCell
            if reschedule == nil {
            if isDLRAdded == false {
                cell.setDLR()
                isDLRAdded = true
                let total = tableView.cellForRow(at: IndexPath(row: upsells.count+3, section: 3)) as! ConfirmationItemTableViewCell
                total.itemPrice.text = "\(((charges?.totalPayableAmount ?? 0.0)).truncate(places: 2)) AUD"
            }
            else {
                cell.removeDLR(reschedule != nil)
                isDLRAdded = false
                let total = tableView.cellForRow(at: IndexPath(row: upsells.count+3, section: 3)) as! ConfirmationItemTableViewCell
                total.itemPrice.text = "\(((charges?.totalPayableAmount ?? 0.0)-(charges?.totalDlr() ?? 0.0)).truncate(places: 2)) AUD"
            }
        }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PaymentViewController {
            vc.invoice = invoiceResponse
            vc.payment = self.payment
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return UITableView.automaticDimension
        case 1,2: return 100
        case 3 : return heightforSection3(row: indexPath.row)
        default:
            return 50
        }
    }
    
    func heightforSection3(row: Int) -> CGFloat{
        switch row {
        case 0, upsells.count + 2, upsells.count + 3 : return 60
        case upsells.count + 1 : return 100
        default:
            return 75
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 250
        case 1,2: return 100
        case 3 : return 70
        default:
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header : SimpleHeader = .fromNib()
        header.headerTitle.setCharacterSpacing(characterSpacing: 1.2)
        switch section {
        case 0: header.headerTitle.text = "Trailer"
        case 1: header.headerTitle.text = "Booking"
        case 2: header.headerTitle.text = "Delivery"
        case 3: header.headerTitle.text = "Pricing"
        default:
            break
        }
        header.headerTitle.text = header.headerTitle.text?.uppercased()
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
    @IBAction func ConfirmTapped(_ sender: Any) {
        if self.reschedule == nil {
            let alert = showLoadingAlert(viewController: self, title: "Preparing Invoice")
            ServiceController.shared.setupCustomerPayment(payment: bookTrailer()) { (status, response) in
                if status {
                    self.payment = response
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true) {
                            self.performSegue(withIdentifier: "payment", sender: Any?.self)
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true) {
                            SPAlert.present(message: response.message ?? "Error", haptic: .error)
                        }
                    }
                }
            }
        } else {
            self.payment = SetupPaymentResponse(stripePaymentIntentId: nil, stripeClientSecret: self.reschedule?.stripeClientSecret,message: "success")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "payment", sender: Any?.self)
            }
        }
        
    }
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}


