//
//  UpcomingBookingTableViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 08/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import SPAlert


class UpcomingBookingTableViewController: UITableViewController {
    
    @IBOutlet weak var trailerName: UILabel!
    @IBOutlet weak var trailerOwner: UILabel!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var trailer = InvoiceDisplayItem()
    var upsells = [InvoiceDisplayItem]()
    var action = "upcoming"
    var isApproved : Int = 0
    var bookingID = ""
    var bookingDetails = InvoiceObj()
    var licenseeDetails = LicenseeObject()
    var trailerdetails : TrailerDetailObject? = nil
    var licenseeName = ""
    var dates : [String]?
    var dlrCharges : Double = 0.0
    var doChargeDLR : Bool = false
    var status = "booked"
    
    var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        primaryButton.addTarget(self, action: #selector(primaryAction(sender:)), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryAction(sender:)), for: .touchUpInside)
        self.trailerOwner.text = licenseeName
        self.trailerName.text = trailer.name

        
        getBookingDetails()
        
        indicator.isHidden = true

        setButtons()

    }
    
    func setButtons(){
        primaryButton.isEnabled = (isApproved != 2) && (status != "returned")
        secondaryButton.isHidden = isApproved == 2
        
        if action == "upcoming" {
            let title = ( isApproved == 2) ? "Booking Cancelled" : "Reschedule Booking"
            primaryButton.setTitle(title,for:.normal)
            secondaryButton.setTitle("Request Cancellation", for: .normal)
        } else {
            primaryButton.setTitle("Request Extension", for: .normal)
            secondaryButton.isHidden = true
        }
        
        if status == "returned"{
            primaryButton.setTitle("Booking Complete",for:.normal)
            secondaryButton.isHidden = true
        }
    }
    
    
    func getBookingDetails() {
        ServiceController.shared.getRental(withID: bookingID) { (status, invoice, error) in
            if status {
                self.bookingDetails = invoice
                self.getLicenseeDetails(invoice.licenseeID ?? "")
                self.getTrailerDetails(invoice.rentedItems?.first?.itemID ?? "")
                let isCancel =  invoice.revisions?.last?.revisionType == "cancellation"
                let cancelRevison = invoice.revisions!.filter{$0.charges != nil}.last
                let revision = isCancel ? cancelRevison : invoice.revisions?.last
                self.trailer.price = revision?.charges?.trailerCharges?.rentalCharges
                self.upsells = invoice.rentedItems!.dropFirst().map({ (item) -> InvoiceDisplayItem in
                    return InvoiceDisplayItem(id:item.totalCharges?.id ?? "", name: item.itemName, photo: item.itemPhoto, price: 0.0, units: 1)
                })
                
                
                for (index, _) in self.upsells.enumerated() {
                    self.upsells[index].price = self.bookingDetails.rentedItems?[index+1].totalCharges?.total
                    self.upsells[index].units = self.bookingDetails.rentedItems?[index+1].units
                    
                    let id = self.upsells[index].id ?? "id"
                    if let charge = revision?.charges?.upsellBaseCharges()[id] {
                        self.upsells[index].price = charge
                    }
                }
                self.doChargeDLR = invoice.doChargeDLR ?? false
                self.isLoaded = true
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            else {
                print(error)
                DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func getLicenseeDetails(_ id : String)  {
        ServiceController.shared.getLicenseeDetails(withLicenseeId: id) { (success, licensee, error) in
            if(success) {
                self.licenseeDetails = licensee
            }
        }
    }
    
    func getTrailerDetails(_ id : String){
        ServiceController.shared.getTrailerDetails(withId: id) { (success, trailerObject, error) in
            if success {
                self.trailerdetails = trailerObject.trailerObj
            }
        }
    }
    
    func setIndicator(load : Bool , title : String){
        DispatchQueue.main.async{
            self.indicator.isHidden = !load
            load ? self.indicator.startAnimating() : self.indicator.stopAnimating()
            self.primaryButton.setTitle(title, for: .normal)
            self.tableView.isUserInteractionEnabled = !load
        }
    }
    
    override func viewDidLayoutSubviews() {
        primaryButton.layer.cornerRadius = primaryButton.frame.height/2
        
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func primaryAction(sender: UIButton) {
        
        let datesVC : DatesViewController = UIStoryboard(storyboard: .main).instantiateViewController()
        datesVC.delegate = self
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let start = dateFormatter.date(from: bookingDetails.rentalPeriod?.start ?? "")
        let end = dateFormatter.date(from: bookingDetails.rentalPeriod?.end ?? "")
        
        dateFormatter.dateFormat = "dd MMM, yyyy"
        let startDate = dateFormatter.string(from: start!)
        let endDate = dateFormatter.string(from: end!)
        
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "HH:mm"
        let startTime = dateFormatter.string(from: start!)
        let endTime = dateFormatter.string(from: end!) 
        
        let type : rentalEditType = (action == "upcoming") ? .reschedule : .extend
        
        let model = EditRentalModel(type: type, bookingID: self.bookingDetails.bookingId ?? "", rentalID: self.bookingDetails.id ?? "", startDate: "", endDate: "")
        datesVC.editRentalModel = model
        if action == "upcoming" {
            datesVC.dates = [startDate, endDate]
            datesVC.times = [startTime, endTime]
            datesVC.requestType = 0
            datesVC.presenter = self
            
            self.present(datesVC, animated: true, completion: nil)
        } else {
            datesVC.dates = [endDate]
            datesVC.times = [endTime]
            datesVC.requestType = 1
            datesVC.presenter = self
            self.present(datesVC, animated: true, completion: nil)
        }
    }
    
    
    
    @objc func secondaryAction(sender: UIButton) {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to send a cancellation?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            self.cancelRequest()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func showMoreDetailsClicked(_ sender: Any) {
        performSegue(withIdentifier: "trailerdetails", sender: nil)
    }
    
    @IBAction func viewLicensee(_ sender: Any) {
        let licensee : LicenseeDetailsViewController = UIStoryboard(storyboard:
            .main).instantiateViewController()
        licensee.licenseeId = self.bookingDetails.licenseeID ?? ""
        if let _ = self.licenseeDetails.name{
            licensee.licenseePresent = true
            licensee.licenseeDetails = self.licenseeDetails
        }
        self.present(licensee,animated: true)
    }
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoaded {
            switch section {
            case 0, 1, 2,3: return 1
            case 4: return upsells.count + (doChargeDLR ? 4 : 3)
            default:
                return 0
            }
        }
        else {
            return 0
        }
    }
    
    func section4Count()->Int{
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0: return setupSection0(indexPath: indexPath)
        case 1: return setupSection1(indexPath: indexPath)
        case 2: return setupSection2(indexPath: indexPath)
        case 3: return setupSection3(indexPath: indexPath)
        case 4: return setupSection4(indexPath: indexPath)
            
        default:
            return UITableViewCell()
        }
    }
    
    func dateSplit() -> [(String, String)]{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let start = dateFormatter.date(from: bookingDetails.revisions?.last?.start ?? "")
        let end = dateFormatter.date(from: bookingDetails.revisions?.last?.end ?? "")
        
        dateFormatter.dateFormat = "dd MMM"
        let startDate = dateFormatter.string(from: start!)
        let endDate = dateFormatter.string(from: end!)
        
        dateFormatter.dateFormat = "hh:mm a"
        let startTime = dateFormatter.string(from: start!)
        let endTime = dateFormatter.string(from: end!)
        
        print("dateSplit:",[(startDate, startTime),(endDate, endTime)])
        return [(startDate, startTime),(endDate, endTime)]
        
    }
    
    func formatDateAndTime() -> [String] {
        let d1 = dateSplit()[0].0
        let t1 = dateSplit()[0].1
        let d2 = dateSplit()[1].0
        let t2 = dateSplit()[1].1
        
        return gmtDateAndTime(dates: [d1,d2], times: [t1,t2], dateformat: "dd MMM", timeformat: "hh:mm a", returnDateFormat: "dd MMM", returnTimeFormat: "hh:mm a", convertToGmt: false)
    }
    
    
    //MARK:- Cells
    
    func setupSection0(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trailerCell", for: indexPath) as! ConfirmationTrailerTableViewCell
        cell.trailerImage.kf.setImage(with: URL(string: trailer.photo?.data ?? ""))
        cell.trailerName.text = trailer.name
        return cell
    }
    
    func setupSection1(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath) as! ConfirmationBookingTableViewCell
        
        let td = formatDateAndTime()
        cell.fromDate.text = td[2]
        cell.fromTime.text = td[0]
        cell.toDate.text = td[3]
        cell.toTime.text = td[1]
        
        return cell
    }   
    
    func setupSection2(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! ConfirmationLocationTableViewCell
        cell.location.text = bookingDetails.dropOffLocation?.text
        return cell
    }
    
    func setupSection3(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "licenseeCell", for: indexPath) as! LicenseeTableViewCell
        cell.licenseeName.text = licenseeName
        return cell
    }
    
    func setupSection4(indexPath: IndexPath) -> UITableViewCell {
        var totalCost = (trailer.price ?? 0)
        
        
        for item in upsells {
            totalCost += (item.price ?? 0)*Double(item.units ?? 1)
        }

        
        let taxes = self.bookingDetails.totalTaxes()
        let damage = (self.bookingDetails.doChargeDLR ?? false) ? self.bookingDetails.totalDlr() : 0
        
    
        let row = indexPath.row
        if row == 0 {
            return setupItemRow(withitem: trailer.name ?? "", andPrice: trailer.price ?? 0)
        }
        if row == upsells.count + 1 {
            return setupItemRow(withitem: "Taxes and VAT", andPrice: taxes)
        }
        
        if (row == upsells.count + 2) && doChargeDLR {
            return setupItemRow(withitem: "Damage Waiver", andPrice: damage)
        }
        
        let totalRow = upsells.count +  (doChargeDLR ? 3 : 2)
        
        if row == totalRow {
            return setupItemRow(withitem: "Grand Total", andPrice: taxes+totalCost+damage)
        }
        else {
            let upsell = upsells[indexPath.row - 1]
            return setupUpsellRow(withPhoto: upsell.photo?.data ?? "", name: upsell.name ?? "", price: (upsell.price ?? 0)*Double(upsell.units
                ?? 1), units: upsell.units ?? 0)
        }
    }
    
    func setupItemRow(withitem name: String, andPrice price: Double) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ConfirmationItemTableViewCell
        cell.itemName.text = name
        cell.itemPrice.text = "\(price.truncate(places: 2)) AUD"
        return cell
    }
    
    func setupUpsellRow(withPhoto url: String, name: String, price: Double, units: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "upsellCell") as! ConfirmationUpsellTableViewCell
        cell.upsellImage.kf.setImage(with: URL(string: url))
        if units > 1 {
            cell.upsellName.text = "\(units) x \(name)"
        }
        else {
            cell.upsellName.text = name
        }
        cell.upsellPrice.text = "\(price.truncate(places: 2)) AUD"
        return cell
    }
    
    
    //MARK:- Heights
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return UITableView.automaticDimension
        case 1,2,3: return 100
        case 4 : return heightforSection4(row: indexPath.row)
        default:
            return 50
        }
    }
    
    func heightforSection4(row: Int) -> CGFloat{
        switch row {
        case 0, upsells.count + 1, upsells.count + 2: return 60
        default:
            return 75
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 250
        case 1,2,3: return 100
        case 4 : return 70
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
        case 3: header.headerTitle.text = "Licensee"
        case 4: header.headerTitle.text = "Pricing"
        default:
            break
        }
        header.headerTitle.text = header.headerTitle.text?.uppercased()
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func rescheduleRequest(dates: [String]) {
        setIndicator(load: true, title: "Preparing Invoice")
        let model = EditRentalModel(type: .reschedule, bookingID: self.bookingDetails.bookingId ?? "", rentalID: self.bookingDetails.id ?? "", startDate: dates[0], endDate: dates[1])
        
        ServiceController.shared.editRental(model: model) { (success,response,error)  in
            DispatchQueue.main.async {
            if success {
                    self.setIndicator(load: false, title: "Reschedule Booking")
                if response?.actionRequired == "payment"{
                    self.performSegue(withIdentifier: "confirm", sender: response)
                }else {
                    SPAlert.present(message: "No action required.", haptic: .success)
                }
            } else {
                self.setIndicator(load: false, title: "Reschedule Booking")
                SPAlert.present(message: error, haptic: .error)
              }
           }
        }
        
    }
    
    
    func extendRequest(dates: [String]) {
        setIndicator(load: true, title: "Preparing Invoice")
        let model = EditRentalModel(type: .extend, bookingID: self.bookingDetails.bookingId ?? "", rentalID: self.bookingDetails.id ?? "", startDate: convertDateForExtension(), endDate: dates[1])
        
        ServiceController.shared.editRental(model: model) { (success,response,error)  in
            if success {
                DispatchQueue.main.async {
                    self.setIndicator(load: false, title: "Request Extension")
                    self.performSegue(withIdentifier: "confirm", sender: response)
                }
            }else {
                DispatchQueue.main.async {
                self.setIndicator(load: false, title: "Request Extension")
                SPAlert.present(message: error, haptic: .error)
                }
            }
        }
    }
    
    func convertDateForExtension()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let date = formatter.date(from : self.bookingDetails.revisions?.last?.start ?? "")
        
        if let date = date {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let final = formatter.string(from: date)
            return final
        } else {
            return ""
        }
    }
    
    func cancelRequest() {
        let model = EditRentalModel(type: .cancel, bookingID: self.bookingDetails.bookingId ?? "", rentalID: self.bookingDetails.id ?? "", startDate: "", endDate: "")
        
        ServiceController.shared.editRental(model: model) { (success,response,error)  in
            DispatchQueue.main.async {
                if success {
                    SPAlert.present(title: "Success",message:response?.message ?? "Request Cancelled",preset: .done)
                    self.isApproved = 2
                    self.setButtons()
                }else {
                    SPAlert.present(message: error,haptic: .error)
                }
            }
        }
    }
    
    @IBAction func unwindToBookings( _ seg: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailsViewcontroller = segue.destination as? BookedTrailerDetailsViewController{
            if let trailer = self.trailerdetails {
                detailsViewcontroller.trailer = trailer
            }
            if let rentedItem = self.bookingDetails.rentedItems?.first{
                detailsViewcontroller.booking = rentedItem.itemID
            }
        }
        
        if let confirmationViewController = segue.destination as? ConfirmationViewController {
            confirmationViewController.reschedule = sender as? RescheduleResponse
            confirmationViewController.trailer = self.trailer
            confirmationViewController.upsells = self.upsells
            confirmationViewController.charges = (sender as? RescheduleResponse)?.booking?.charges
        }
    }
    
}


extension UpcomingBookingTableViewController : DatesDelegate, TimesDelegate {
    
    func returnDates(dates: [String]) {    }
    
    func returnTimes(times: [String]) {    }
    
    func returnDateAndTime(dates: [String], times: [String]) {
        if action == "upcoming" {
            rescheduleRequest(dates: convertGMT(dates: dates, times: times))
        } else {
            extendRequest(dates: convertGMT(dates: dates, times: times))
        }
    }
    
    func convertGMT(dates:[String],times:[String])->[String] {
        
        print("DATES: ",dates)
        print("TIMES: ",times)
        var sDate = dates.first
        var eDate = dates.last
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd MMM, yyyy"
        let start = dateformatter.date(from: sDate!)
        let end = dateformatter.date(from: eDate!)
        
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        sDate = dateformatter.string(from: start!)
        eDate = dateformatter.string(from: end!)
        
        var sTime = times.first
        var eTime = times.last
        
        dateformatter.dateFormat = "HH:mm"
        dateformatter.timeZone = .current
        
        
        let startTime = dateformatter.date(from: sTime!)
        let endTime = dateformatter.date(from: eTime!)
        
        dateformatter.dateFormat = "HH:mm"
        dateformatter.timeZone = TimeZone(abbreviation: "UTC")

        
        //DATES:  ["03 Nov, 2020", "03 Nov, 2020"]
        //TIMES:  ["12:00 PM", "14:00"]
        
        sTime = dateformatter.string(from: startTime!)
        eTime = dateformatter.string(from: endTime!)
        
        let finalStart = sDate! + " " + sTime!
        let finalEnd = eDate! + " " + eTime!
        
        let arr = [finalStart,finalEnd]
                
        return arr
    }
    
    func convertTimeFormat(_ time: [String])->[String]{
        var sTimeString = time[0]
        var eTimeString = time[1]
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "hh:mm a"
        if let sTime = dateformatter.date(from: sTimeString){
            let dateformatter2 = DateFormatter()
            dateformatter2.dateFormat = "HH:mm"
            sTimeString = dateformatter2.string(from: sTime)
        }
        
        if let eTime = dateformatter.date(from: eTimeString){
            let dateformatter2 = DateFormatter()
            dateformatter2.dateFormat = "HH:mm"
            eTimeString = dateformatter2.string(from: eTime)
        }
        return [sTimeString,eTimeString]
    }
    
}


extension UpcomingBookingTableViewController : licenseeDelegate, bookedTrailerDelegate
{
    func didGetLicenseeDetails(licensee: LicenseeObject) {
        self.licenseeDetails = licensee
    }
    
    func didGetTrailerDetails(trailer: TrailerDetailObject) {
        self.trailerdetails = trailer
    }
    
}
