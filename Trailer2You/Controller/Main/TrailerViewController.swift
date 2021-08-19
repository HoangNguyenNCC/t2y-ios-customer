//
//  TrailerViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 21/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import Kingfisher
import MapKit
import SPAlert
import ProgressHUD

class TrailerViewController: UIViewController {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var trailerTableView: UITableView!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var sortingButton: UIButton!
    @IBOutlet weak var SearchEditView: UIView!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var datesButton: UIButton!
    @IBOutlet weak var timesButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var editFrame = CGAffineTransform()
    var booking = BookingModel()
    var address: String = ""
    var location: [Double] = []
    var dates: [String] = []
    var times: [String] = []
    var trailers = [TrailerResult]()
    var allTrailers = [TrailerResult]()
    
    var filteredTrailers = [TrailerResult]() {
        didSet{   emptyError()   }
    }
    
    var filters = Filters()
    var filterItems = [FilterItems]()
    var sort = Sort()
    var index = [Int]()
    var isSorting = false
    var selectedTrailer = TrailerResult()
    
    var filterSettings = [false,false,false]
    var sortSettings = [false,false,false]
    
    var selectedtrailer : String?
    
    var isDataLoading:Bool=false
    var page = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        editFrame = SearchEditView.transform
        location = booking.address!.coordinates!
        dates = booking.dates!
        times = booking.times!
        
        searchField.layer.cornerRadius = 12
        searchField.makeBordered()
        searchField.setPadding()
        
        trailerTableView.delegate = self
        trailerTableView.dataSource = self
        overrideUserInterfaceStyle = .light
        setLabels()
        searchField.delegate = self
        searchField.inputView = UIView()
        addressField.delegate = self
        addressField.inputView = UIView()
        filtersButton.setupButton(isTapped: false, text: "Filters")
        datesButton.setTitleColor(.primary, for: .normal)
        timesButton.setTitleColor(.primary, for: .normal)
        SearchEditView.transform = CGAffineTransform(translationX: 0, y: -SearchEditView.frame.height)
        SearchEditView.alpha = 0.0
        sortingButton.setupButton(isTapped: false, text: "Sort")
        getFilters()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.trailers.count == 0{
            ProgressHUD.show("Fetching Trailers", interaction: true)
            ProgressHUD.animationType = .circleStrokeSpin
            ProgressHUD.colorAnimation = .primary
        }
        getTrailers()
    }
    
    func emptyError(){
        if isSorting && filteredTrailers.isEmpty {
            self.errorAlert(#imageLiteral(resourceName: "Combined Shape"), nil, error: nil)
        }
    }
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        setCard()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        closeCard()
    }
    
    
    
    
    func sortTrailers(sort: Sort) {
        if sort.crit == .pricing {
            isSorting = true
            if sort.type == .ascending {
                filteredTrailers = trailers.sorted { (t1, t2) -> Bool in
                    let price1 = Double(t1.price?.replacingOccurrences(of: " AUD", with: "") ?? "0") ?? 0
                    let price2 = Double(t2.price?.replacingOccurrences(of: " AUD", with: "") ?? "0") ?? 0
                    return price1 < price2
                }
                trailerTableView.reloadData()
            }
            else {
                filteredTrailers = trailers.sorted { (t1, t2) -> Bool in
                    let price1 = Double(t1.price?.replacingOccurrences(of: " AUD", with: "") ?? "0") ?? 0
                    let price2 = Double(t2.price?.replacingOccurrences(of: " AUD", with: "") ?? "0") ?? 0
                    return price1 > price2
                }
                trailerTableView.reloadData()
            }
        }
        else if sort.crit == .distance {
            if sort.type == .ascending {
                trailers = trailers.sorted { (t1, t2) -> Bool in
                    let dist1 = Double(t1.licenseeDistance?.replacingOccurrences(of: " km", with: "") ?? "0") ?? 0
                    let dist2 = Double(t2.licenseeDistance?.replacingOccurrences(of: " km", with: "") ?? "0") ?? 0
                    return dist1 < dist2
                }
                trailerTableView.reloadData()
            }
            else {
                trailers = trailers.sorted { (t1, t2) -> Bool in
                    let dist1 = Double(t1.licenseeDistance?.replacingOccurrences(of: " km", with: "") ?? "0") ?? 0
                    let dist2 = Double(t2.licenseeDistance?.replacingOccurrences(of: " km", with: "") ?? "0") ?? 0
                    return dist1 > dist2
                }
                trailerTableView.reloadData()
            }
        }
        else if sort.crit == .rating {
            isSorting = true
            if sort.type == .five {
                filteredTrailers = trailers.filter({ (t) -> Bool in
                    return t.rating == 5
                })
            }
            else if sort.type == .fourPlus {
                filteredTrailers = trailers.filter({ (t) -> Bool in
                    return t.rating ?? 0 >= 4
                })
            }
            else if sort.type == .threePlus {
                filteredTrailers = trailers.filter({ (t) -> Bool in
                    return t.rating ?? 0 >= 3
                })
            }
            trailerTableView.reloadData()
        }
        else {
            isSorting = false
            trailerTableView.reloadData()
        }
    }
    
    func getTrailers(filters: [String: [String]] = [String: [String]](),skip:Int=0,count:Int=30) {
        let dateArray = gmtDateAndTime(dates: dates, times: times, dateformat: "dd MMM, yyyy", timeformat: nil, returnDateFormat: "dd MMM, yyyy", returnTimeFormat: "h:mm a", convertToGmt: true)
        ServiceController.shared.searchTrailers(location: location, dates: [dateArray[2],dateArray[3]], times: [dateArray[0],dateArray[1]], filters: filters,skip: skip, count: count) {
            (status, trailers, error) in
            if status {
                if trailers.count == 0 {
                    self.trailers = []
                    ProgressHUD.showFailed("No trailers found", interaction: true)
                    return
                }
                self.trailers = trailers
                self.allTrailers = trailers
                self.featured()
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                    self.trailerTableView.reloadData()
                    self.trailerTableView.alpha = 1
                }
            } else {
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                    self.trailerTableView.alpha = 1
                    self.displayalert(error)
                }
            }
        }
    }
    
    func getGMTdatetime() -> [String] {
            let dateformatter = DateFormatter()
            dateformatter.timeZone = .current
            dateformatter.timeStyle = .short
            let t1 = dateformatter.date(from: times[0])
            let t2 = dateformatter.date(from: times[1])
        
            dateformatter.dateFormat = "dd MMM, yyyy HH:mm:ss"
    
            let d1 = dateformatter.date(from: dates[0])
            let d2 = dateformatter.date(from: dates[1])
            
            print("d1 is:",d1)
            var startDateComponent = DateComponents()
            startDateComponent.hour = Calendar.current.component(.hour, from: t1!)
            startDateComponent.minute = Calendar.current.component(.minute, from: t1!)
        let finalStartDate = Calendar.current.date(byAdding: startDateComponent, to: d1!)!
        
            var endDateComponent = DateComponents()
            endDateComponent.hour = Calendar.current.component(.hour, from: t2!)
            endDateComponent.minute = Calendar.current.component(.minute, from: t2!)
            let finalEndDate = Calendar.current.date(byAdding: startDateComponent, to: d2!)!
        
            
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = "h:mm a"
        
        let ft1 = formatter.string(from: finalStartDate)
        let ft2 = formatter.string(from: finalEndDate)
        
        formatter.dateFormat = "dd MMM, yyyy"

        let fd1 = formatter.string(from: finalStartDate)
        let fd2 = formatter.string(from: finalEndDate)
        
            return [ft1,ft2,fd1,fd2]
    }
    
    func featured(){
        guard let trailer = selectedtrailer else { return }
        let modelFilters = filters.trailerModelList?.filter { $0.name == trailer }
        guard let filter = modelFilters else { return }
        didAddFilters(filters:filter,  delivery: .door2door, filterSettings: filterSettings)
    }
    
    func displayalert(_ error : Error){
        if let errors = error.errors {
            if errors.count > 0 {
                self.errorAlert(nil, .error, error: errors.first)
            }
        }
    }
    
    @IBAction func datesEdited(_ sender: Any) {
        let datesVC : DatesViewController = UIStoryboard(storyboard:
                                                            .main).instantiateViewController()
        datesVC.dates = dates
        datesVC.times = self.times
        datesVC.presenter = self
        datesVC.delegate = self
        self.present(datesVC, animated: true)
    }
    
    @IBAction func timeEdited(_ sender: Any) {
        let timeVC : DurationViewController = UIStoryboard(storyboard: .main).instantiateViewController()
        timeVC.booking.dates = dates
        timeVC.presenter = self
        timeVC.delegate = self
        timeVC.times = self.times
        self.present(timeVC, animated: true)
    }
    
    
    @IBAction func backClicked(_ sender: Any) {
        showCancelAlert()
    }
    
    
    func getFilters() {
        ServiceController.shared.getFilterItems { (status, filters , error) in
            if status {
                self.filters = filters
            }
            else{
                print(error)
            }
        }
    }
    
    func dateString(dates: [String]) -> String {
        let date1 = dates[0].split(separator: ",")[0]
        let date2 = dates[1].split(separator: ",")[0]
        return "\(date1) - \(date2)"
    }
    
    func timeString(times: [String]) -> String{
        let time1 = times[0]
        let time2 = times[1]
        return "\(time1) - \(time2)"
    }
    
    @IBAction func filtersTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "filters", sender: Any?.self)
    }
    
    @IBAction func sortingTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "sorting", sender: Any?.self)
    }
    
    
    func filterTrailers(filters: [FilterItems], delivery : DeliveryMethod) {
        let filterCodes = filters.map({ (filter) -> String in
            return (filter.code ?? "")
        })
        let filterNames = filters.map { (filter) -> String in
            return (filter.name ?? "")
        }
        frontendfilter(filterNames + filterCodes)
    }
    
    func frontendfilter(_ names : [String]){
        if !names.isEmpty{
            let filter = self.allTrailers
            print(names)
            let filteredTrailers = filter.filter { names.contains($0.type ?? "") || names.contains($0.name ?? "")}
            self.trailers = filteredTrailers
            if self.trailers.isEmpty{
                self.errorAlert(#imageLiteral(resourceName: "box-trailer"), nil, error: nil)
            }
        } else {
            self.trailers = self.allTrailers
        }
        DispatchQueue.main.async {
            self.trailerTableView.reloadData()
        }
    }
    
}

extension TrailerViewController : UITableViewDelegate, UITableViewDataSource, FilterDelegate, SortingDelegate, DatesDelegate,TimesDelegate, addressCompletionDelegate {
    
    func returnDateAndTime(dates: [String], times: [String]) {    }
    
    
    func didCompleteAddress(address: AddressRequest) {
        self.address = address.country ?? ""
        self.location = address.coordinates ?? [Double]()
        self.booking.address = address
        setLabels()
        closeTapped((Any).self)
        getTrailers()
        ProgressHUD.show("updating search address", interaction: true)
    }
    
    
    func returnDates(dates: [String]) {
        self.dates = dates
        self.booking.dates = dates
        setLabels()
        closeTapped((Any).self)
        getTrailers()
        ProgressHUD.show("updating search dates", interaction: true)
    }
    
    func returnTimes(times: [String]) {
        self.times = times
        self.booking.times = times
        setLabels()
        closeTapped(Any.self)
        getTrailers()
        ProgressHUD.show("updating search times", interaction: true)
    }
    
    func didAddFilters(filters : [FilterItems], delivery: DeliveryMethod,filterSettings : [Bool]) {
        self.filterSettings = filterSettings
        filterTrailers(filters: filters, delivery: delivery)
        if filters.count > 0 {
            self.filterItems = filters
            setFilters(filterCount: filters.count)
        }
        else {
            filtersButton.setupButton(isTapped: false, text: "Filters")
        }
    }
    
    func didReturnSorting(sort: Sort, index: [Int],sortSettings : [Bool]) {
        self.sort = sort
        self.index = index
        self.sortSettings = sortSettings
        setSort(sort: sort)
        sortTrailers(sort: sort)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSorting {
            return filteredTrailers.count
        }
        return trailers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trailerCell") as! TrailerTableViewCell
        var trailer = TrailerResult()
        if isSorting {
            trailer = filteredTrailers[indexPath.row]
        }
        else {
            trailer = trailers[indexPath.row]
        }
        cell.trailerImageView.kf.setImage(with: URL(string: trailer.photo?[0].data ?? ""))
        cell.trailerNameLabel.text = trailer.name
        cell.trailerPriceLabel.text = trailer.price
        cell.trailerOwnerLabel.text = trailer.licenseeName
        cell.upsellsLabel.text = "\(trailer.upsellItems?.count ?? 0)" + (trailer.upsellItems?.count == 1 ? " add on" : " add ons")
        cell.setUpsellLabel((trailer.upsellItems?.count == 0 ? false : true))
        cell.trailerDistanceLabel.text = cleanDistance(distance: trailer.licenseeDistance ?? "0")
        return cell
    }
    
    func cleanDistance(distance: String) -> String{
        let doubleDistance = (Double(distance.replacingOccurrences(of: " km", with: "")) ?? 0.0) * 1000
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        return formatter.string(from: Measurement(value: doubleDistance, unit: UnitLength.meters))
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSorting {
            selectedTrailer = filteredTrailers[indexPath.row]
        } else {
            selectedTrailer = trailers[indexPath.row]
        }
        self.performSegue(withIdentifier: "trailerDetails", sender: Any?.self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FilterTableViewController {
            vc.filters = filters
            vc.filterItems = filterItems
            vc.sectionsareCollapsed = filterSettings
            vc.delegate = self
        }
        if let vc = segue.destination as? SortingTableViewController {
            vc.selectedSort = sort
            vc.index = index
            vc.sectionsareCollapsed = sortSettings
            vc.delegate = self
        }
        if let vc = segue.destination as? TrailerDetailsViewController {
            booking.id = selectedTrailer.rentalItemId!
            vc.booking = booking
            vc.dateTime = [times[0],times[1],dates[0],dates[1]]
        }
    }
}

extension TrailerViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchField {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                self.SearchEditView.transform = self.editFrame
                self.SearchEditView.alpha = 1
                self.cancelButton.isHidden = true
            }, completion: nil)
        }
        
        if textField == addressField {
            let addressFinderVC : AddressViewController = UIStoryboard(storyboard: .main).instantiateViewController()
            if let address = self.booking.address{
                addressFinderVC.addressCore = address
            }
            addressFinderVC.delegate = self
            textField.resignFirstResponder()
            self.present(addressFinderVC, animated: true)
        }
    }
}

extension UIButton {
    
    func setupButton(isTapped: Bool, text: String, icon: Symbol = .none) {
        DispatchQueue.main.async {
            self.layer.cornerRadius = self.frame.height/2
            self.tintColor = .white
            if isTapped {
                self.setTitleColor(.white, for: .normal)
                self.backgroundColor = #colorLiteral(red: 0, green: 0.2, blue: 0.7450980392, alpha: 1)
                if icon != .none {
                    self.setTitle("  "+text, for: .normal)
                    self.setImage(UIImage(systemName: icon.rawValue), for: .normal)
                }
                else {
                    self.setTitle(text, for: .normal)
                    self.setImage(UIImage(), for: .normal)
                }
            }
            else {
                self.setTitle(text, for: .normal)
                self.setImage(UIImage(), for: .normal)
                self.setTitleColor(#colorLiteral(red: 0, green: 0.2, blue: 0.7450980392, alpha: 1), for: .normal)
                self.backgroundColor = .quaternarySystemFill
            }
        }
    }
    
}

extension TrailerViewController : addressDelegate {
    func didEnterAddress(address: Address) {
        print(address)
        self.address = address.addressModel.area ?? "Australia"
        self.location = address.addressRequest.coordinates ?? [Double]()
        self.booking.address = address.addressRequest
        setLabels()
        closeTapped((Any).self)
        getTrailers()
    }
}


extension UIViewController {
    
    func gtmTime(dates:[String]) -> [String] {
        let formatter = DateFormatter()
        let dateformatter = DateFormatter()
        dateformatter.timeStyle = .short
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt1 = dateformatter.date(from: dates[0])
        let dt2 = dateformatter.date(from: dates[1])
        formatter.dateFormat = "h:mm a"
        return [formatter.string(from: dt1!),formatter.string(from: dt2!)]
    }
    
    func gmtToLocal(_ time : String)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        if let date = formatter.date(from: time){
            formatter.dateFormat = "hh:mm a"
            formatter.timeZone = .current
            
            print("gmtToLocal:",time," to ",date)
            return   formatter.string(from: date)
        } else {
            formatter.dateFormat = "HH:mm"
            if let date = formatter.date(from: time){
                formatter.dateFormat = "hh:mm a"
                formatter.timeZone = .current
                
                print("gmtToLocal:",time," to ",date)
                return   formatter.string(from: date)
            } else {
                return time
            }
        }
    }
    
    func gmtDateAndTime(dates:[String],times:[String],dateformat:String,timeformat:String?,returnDateFormat:String,returnTimeFormat:String,convertToGmt:Bool) -> [String] {
        
        let formatter = DateFormatter()
        formatter.timeZone = convertToGmt ? TimeZone.current : TimeZone(abbreviation: "UTC")
        
        
        if let tf = timeformat { formatter.dateFormat = tf } else {
            formatter.timeStyle = .short
        }
        print("TTT: ",times)
        let startTime = formatter.date(from: times[0])!
        let endTime = formatter.date(from: times[1])!
        
        formatter.dateFormat = dateformat
        let startDate = formatter.date(from: dates[0])!
        let endDate = formatter.date(from: dates[1])!
    
        let start = Calendar.current.date(from: getDateComponents(startDate, startTime))!
        let end = Calendar.current.date(from:  getDateComponents(endDate, endTime))!
        
        formatter.timeZone = !convertToGmt ? TimeZone.current : TimeZone(abbreviation: "UTC")
        formatter.dateFormat = returnDateFormat
        let fd1 = formatter.string(from: start)
        let fd2 = formatter.string(from: end)
        
        formatter.dateFormat = returnTimeFormat
        
        let ft1 = formatter.string(from: start)
        let ft2 = formatter.string(from: end)
        
        return [ft1,ft2,fd1,fd2]
    }
    
    func getDateComponents(_ date: Date,_ time:Date) -> DateComponents {
        var comp = DateComponents()
        comp.day = Calendar.current.component(.day, from: date)
        comp.month = Calendar.current.component(.month, from: date)
        comp.year = Calendar.current.component(.year, from: date)
        comp.hour = Calendar.current.component(.hour, from: time)
        comp.minute = Calendar.current.component(.minute, from: time)
        return comp
    }
    
    
}


//MARK: UI SETUP
extension TrailerViewController {
    func setLabels() {
        searchField.text = "\(address)  •  \(dateString(dates: dates))".uppercased()
        searchField.setCharacterSpacing(characterSpacing: 1.15)
        timesButton.setTitle(timeString(times: times), for: .normal)
        datesButton.setTitle(dateString(dates: dates), for: .normal)
        addressField.text = booking.address?.text
    }
    
    func setCard(){
        addressField.setPadding()
        addressField.makeRoundedCorners(usingCorners: [.topLeft, .topRight], cornerRadii: 12)
        datesButton.makeRoundedCorners(usingCorners: [.bottomLeft], cornerRadii: 12)
        timesButton.makeRoundedCorners(usingCorners: [ .bottomRight], cornerRadii: 12)
        SearchEditView.layer.cornerRadius = 12
        SearchEditView.makeTopCard()
    }
    
    func closeCard(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.SearchEditView.transform = CGAffineTransform(translationX: 0, y: -self.SearchEditView.frame.height)
            self.SearchEditView.alpha = 0
            self.cancelButton.isHidden = false
        }, completion: { (true) in
            self.searchField.resignFirstResponder()
        })
    }
    
    func setFilters(filterCount: Int) {
        filtersButton.setupButton(isTapped: true, text: "FILTERS • \(filterCount)")
    }
    
    func setSort(sort: Sort) {
        
        sortingButton.setupButton(isTapped: false, text: "Sort")
        
        if sort.crit == .pricing || sort.crit == .distance {
            if sort.type == .ascending {
                sortingButton.setupButton(isTapped: true, text: sort.crit?.rawValue.uppercased() ?? "", icon: .up)
            }
            else {
                sortingButton.setupButton(isTapped: true, text: sort.crit?.rawValue.uppercased() ?? "", icon: .down)
            }
        }
        else if sort.crit == .rating {
            if sort.type == .five {
                sortingButton.setupButton(isTapped: true, text: "5", icon: .star)
            }
            else if sort.type == .fourPlus {
                sortingButton.setupButton(isTapped: true, text: "4+", icon: .star)
            }
            else if sort.type == .threePlus {
                sortingButton.setupButton(isTapped: true, text: "3+", icon: .star)
            }
        }
        
    }
    
    func showCancelAlert(){
        let alert = UIAlertController(title: "Cancel search", message: "Are you sure you want to cancel this search?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "YES", style: .destructive) { (UIAlertAction) in
            self.performSegue(withIdentifier: "home", sender: nil)
        }
        let no = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(no)
        
        self.present(alert,animated: true)
    }
    
    func errorAlert(_ image : UIImage?,_ preset : SPAlertIconPreset?,error:String?){
        DispatchQueue.main.async {
            if let image = image{
                let alertView = SPAlertView(title: "Uh Oh!", message: "No trailers found.", preset: .custom(image))
                alertView.present()
            } else {
                let alertView = SPAlertView(message: error ?? "Error")
                alertView.present()
            }
        }
    }
    
}


extension TrailerViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        print("scrollViewWillBeginDragging")
        isDataLoading = false
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }
    
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        print("scrollViewDidEndDragging")
        if ((trailerTableView.contentOffset.y + trailerTableView.frame.size.height) >= trailerTableView.contentSize.height)
        {
            if !isDataLoading{
                isDataLoading = true
                self.page += 5
                //  self.getTrailers(skip: page,count: page+5)
            }
        }
    }
}
