//
//  TrailerDetailsViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 13/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import Kingfisher
import ProgressHUD

class TrailerDetailsViewController: UIViewController {
    
    var booking = BookingModel()
    var charges : ChargesResponseModel?
    var selectedUpsellTags : [Int] = []
    var dateTime = [String]()
    var invoice = Invoice()
    var items = [InvoiceDisplayItem]()
    var upsellQunatity: [String:Int] = [:]
    
    @IBOutlet weak var trailerDetailView: UIScrollView!
    @IBOutlet weak var upsellTable: UITableView!
    @IBOutlet weak var trailerTare: UILabel!
    @IBOutlet weak var trailerCapacity: UILabel!
    @IBOutlet weak var trailerAge: UILabel!
    @IBOutlet weak var licenseeHeadline: UILabel!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var trailerImage: UIImageView!
    @IBOutlet weak var trailerDescription: UILabel!
    @IBOutlet weak var trailerRating: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var insuranceStatus: UILabel!
    @IBOutlet weak var serviceStatus: UILabel!
    @IBOutlet weak var licenseeImage: UIImageView!
    @IBOutlet weak var licenseeName: UILabel!
    @IBOutlet weak var viewBttn: UIButton!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var licenseeView: UIView!
    @IBOutlet weak var trailersBttn: UIButton!
    @IBOutlet weak var upsellBttn: UIButton!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var trailerTitle: UILabel!
    @IBOutlet weak var trailerPrice: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var rentButton: UIButton!
    
    var trailerResponse = TrailerDetailResponse()
    var trailer = TrailerObject()
    var upsell : [UpsellItemsList] = []
    var selectedUpsell : [UpsellItemsList] = []
    var licensee: String = ""
    var trailerName: String = ""
    var licenseeDetails = LicenseeObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        trailerDetailView.alpha = 0
        upsellTable.estimatedRowHeight = 400
        upsellTable.rowHeight = UITableView.automaticDimension
        
        trailersBttn.setupButton(isTapped: true, text: "Trailers")
        upsellBttn.setupButton(isTapped: false, text: "Upsell Items")
        
        booking.times = gtmTime(dates: booking.times!)
        
        getTrailerDetails()
        self.view.bringSubviewToFront(trailerDetailView)
        self.view.bringSubviewToFront(bottomBar)
        indicator.isHidden = true

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        photoCollection.dataSource = self
        photoCollection.delegate = self
        
        upsellTable.dataSource = self
        upsellTable.delegate = self
        
        if self.trailerResponse.message == nil {
            ProgressHUD.show("Loading...", icon: .cart, interaction: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        bottomBar.makeBottomCard()
        trailerImage.layer.cornerRadius = 12
        licenseeView.layer.cornerRadius = 12
        priceView.layer.cornerRadius = 12
        trailersBttn.layer.cornerRadius = trailersBttn.frame.height/2
        upsellBttn.layer.cornerRadius = upsellBttn.frame.height/2
        viewBttn.layer.cornerRadius = viewBttn.frame.height/2
        viewBttn.setupButton(isTapped: false, text: "View")
        licenseeHeadline.setCharacterSpacing(characterSpacing: 1.1)
    }
    
    func getTrailerDetails() {
        ServiceController.shared.getTrailer(withBooking: booking) { (success, trailerObject, error) in
            DispatchQueue.main.async {
                if success {
                    self.trailerResponse = trailerObject
                    self.trailer = self.trailerResponse.trailerObj!
                    self.getLicenseeDetails()
                    self.getTrailerDetail()
                    self.photoCollection.reloadData()
                    self.upsellTable.reloadData()
                    self.trailerDetailView.alpha = 1
                    ProgressHUD.dismiss()
                    self.trailerPrice.text = self.trailer.total?.stringvalue
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func getLicenseeDetails()  {
        ServiceController.shared.getLicenseeDetails(withLicenseeId: self.trailer.licenseeID ?? "") { (success, licensee, _) in
                if success { self.licenseeDetails = licensee }
        }
    }

    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getTrailerDetail() {
        let processor = DownsamplingImageProcessor(size: trailerImage.bounds.size) |> RoundCornerImageProcessor(cornerRadius: 20)
        licensee = trailerResponse.licenseeObj?.licenseeName ?? ""
        licenseeHeadline.text = licensee.uppercased()
        trailerRating.text = String(trailer.rating ?? 0) + " / 5"
        trailerName = trailerResponse.trailerObj?.name ?? ""
        trailerTitle.text = trailerName
        if let photo = trailer.photos?.first{
            trailerImage.kf.setImage(
                with: URL(string: photo.data ?? ""),
                placeholder: UIImage(named: "placeholderImage"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ])
        }
        trailerDescription.text = trailer.trailerObjDescription!
        
        sizeLabel.text = trailer.size ?? "size"
        trailerAge.text = "\(trailer.age ?? 1)"
        trailerCapacity.text = trailer.capacity?.formattedValue ?? "capacity"
        trailerTare.text = trailer.tare?.formattedValue ?? "tare"
        licenseeName.text = trailerResponse.licenseeObj?.ownerName
        
        insuranceStatus.text = (trailer.insured ?? false) ? "✅" : "❌"
        serviceStatus.text = (trailer.serviced ?? false) ? "✅" : "❌"
    }
    
    @IBAction func upsellBttnTapped(_ sender: Any) {
        trailerDetailView.scrollToTop()
        trailerDetailView.isUserInteractionEnabled = false
        trailersBttn.setupButton(isTapped: false, text: "Trailers")
        licenseeHeadline.text = trailerName.uppercased()
        trailerTitle.text = "Upsell Items"
        upsellBttn.setupButton(isTapped: true, text: "Upsell Items")
        self.view.bringSubviewToFront(upsellTable)
        self.view.bringSubviewToFront(bottomBar)
    }
    
    @IBAction func trailerBttnTapped(_ sender: Any) {
        trailerDetailView.isUserInteractionEnabled = true
        trailersBttn.setupButton(isTapped: true, text: "Trailers")
        licenseeHeadline.text = licensee.uppercased()
        trailerTitle.text = trailerName
        upsellBttn.setupButton(isTapped: false, text: "Upsell Items")
        self.view.bringSubviewToFront(trailerDetailView)
        self.view.bringSubviewToFront(bottomBar)
    }
    
    func rentalSetup() {
        items.removeAll()
        invoice.rentedItems = []
        let trailerRentalItem = RentedItem(itemType: .trailer, itemId: trailer.id, units: 1)
        invoice.rentedItems?.append(trailerRentalItem)
        var upsellRentalItems = [RentedItem]()
        
        for (key,value) in upsellQunatity {
            let item = RentedItem(itemType: .upsellitem, itemId: key, units: value)
            upsellRentalItems.append(item)
        }
        
        for upsellItem in upsellRentalItems {
            invoice.rentedItems?.append(upsellItem)
        }
        
        items.append(InvoiceDisplayItem(name: trailer.name, photo: trailer.photos?.first, price: Double(trailer.totalCharges?.total?.stringvalue ?? "0")))
        
        for tag in selectedUpsellTags {
            if let upsellId = trailerResponse.upsellItemsList?[tag].id{
                let qty = Double(upsellQunatity[upsellId] ?? 0)
                if qty > 0 {
            let itemPrice = trailerResponse.upsellItemsList?[tag].totalCharges?.rentalCharges?.stringvalue ?? "0"
            
            let item = InvoiceDisplayItem(id:trailerResponse.upsellItemsList?[tag].id, name: trailerResponse.upsellItemsList?[tag].name, photo: trailerResponse.upsellItemsList?[tag].photo?[0], price: qty*Double(itemPrice)!, units: Int(qty))
            items.append(item)
                }
            }
        }
    }
    
    
    @IBAction func rentTapped(_ sender: Any) {
        rentalSetup()
        invoice.description = "Trailer rental from \(booking.dates![0]) to \(booking.dates![1])"
        invoice.doChargeDLR = true
        invoice.isPickup = false
        
        invoice.licenseeId = trailerResponse.licenseeObj?.licenseeId
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy hh:mm a"
        let startDate = dateFormatter.date(from: (booking.dates?[0])!+" "+(booking.times?[0])!)
        let endDate = dateFormatter.date(from: (booking.dates?[1])!+" "+(booking.times?[1])!)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let startDateString = dateFormatter.string(from: startDate!)
        let endDateString = dateFormatter.string(from: endDate!)
        
        invoice.rentalPeriod = RentalPeriod(start: startDateString, end: endDateString)
        invoice.pickUpLocation = Location(text: booking.address?.text, pincode: booking.address?.pincode, coordinates: booking.address?.coordinates)
        invoice.dropOffLocation = Location(text: booking.address?.text, pincode: booking.address?.pincode, coordinates: booking.address?.coordinates)
        
        var model = items.map { upsellObject(id: $0.id ?? "", quantity: $0.units ?? 1)}
        
        let trailer = model.removeFirst()
          
        let req = ChargesRequestModel(trailerId: self.booking.id ?? "" , upsellItems: model, startDate: startDateString, endDate: endDateString, isPickup: false)
        
        loadButton(true)
        
        ServiceController.shared.getCharges(req) { (success, response, error) in
            self.loadButton(false)
            if success{
                self.charges = response
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "confirm", sender: Any?.self)
                }
            } else {
                ProgressHUD.showError(error.errors?.first, interaction: true)
            }
        }
    }
    
    func loadButton(_ status : Bool){
        DispatchQueue.main.async {
            self.indicator.isHidden = !status
            status ? self.indicator.startAnimating() : self.indicator.stopAnimating()
            let title = status ? "Generating Invoice" : "Rent Trailer"
            self.rentButton.setTitle(title, for: .normal)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let confirmVC = segue.destination as? ConfirmationViewController {
            confirmVC.invoice = invoice
            confirmVC.displayItems = items
            confirmVC.damageCharges = trailer.totalCharges?.dlrCharges?.stringvalue ?? "0.0 AUD"
            confirmVC.booking = self.booking
            confirmVC.charges = self.charges
        }
        if let licenseeVC = segue.destination as? LicenseeDetailsViewController {
            licenseeVC.licenseeId = trailerResponse.licenseeObj?.licenseeId ?? ""
            licenseeVC.trailerName = trailer.name ?? ""
            licenseeVC.delegate = self
            if let _ = self.licenseeDetails.name{
                licenseeVC.licenseePresent = true
                licenseeVC.licenseeDetails = self.licenseeDetails
            }
        }
    }
}

extension TrailerDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trailer.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trailer", for: indexPath) as! PhotoCell
        let url = URL(string: trailer.photos![indexPath.row].data ?? "")
        let processor = DownsamplingImageProcessor(size: cell.trailerPhoto.bounds.size) |>
            RoundCornerImageProcessor(cornerRadius: 8)
        cell.trailerPhoto.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
        ])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        self.trailerImage.image = cell.trailerPhoto.image
    }
}

extension TrailerDetailsViewController: UITableViewDataSource, UITableViewDelegate, UpsellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trailerResponse.upsellItemsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "upsellItem", for: indexPath) as! UpsellCell
        cell.nameLabel.text = trailerResponse.upsellItemsList?[indexPath.row].name?.uppercased()
        
        cell.nameLabel.setCharacterSpacing(characterSpacing: 1.2)
        if let rating = trailerResponse.upsellItemsList?[indexPath.row].rating{
            cell.ratingLabel.text = "\(rating) / 5"
            cell.ratingLabel.isHidden = (rating == 0)
        }
        if let str = trailerResponse.upsellItemsList?[indexPath.row].photo?.first?.data, let url = URL(string : str){
        cell.upsellImage.kf.setImage(with: url)
        }
        cell.upsellDescription.text = trailerResponse.upsellItemsList?[indexPath.row].upsellItemsListDescription!
        cell.upsellItemCost.text = trailerResponse.upsellItemsList?[indexPath.row].totalCharges?.total?.stringvalue
        cell.addItem.tag = indexPath.row 
        if(trailerResponse.upsellItemsList?[indexPath.row].isAvailableForRent ?? false) {
            cell.availabilityLabel.text = "AVAILABLE"
            cell.availabilityLabel.setCharacterSpacing(characterSpacing: 1.1)
            cell.availabilityLabel.backgroundColor = .systemGreen
        } else {
            cell.availabilityLabel.text = "UNAVAILABLE"
            cell.availabilityLabel.setCharacterSpacing(characterSpacing: 1.1)
            cell.availabilityLabel.backgroundColor = .systemGreen
        }
        
        if(selectedUpsellTags.contains(indexPath.row)) {
            cell.addItem.setupButton(isTapped: false, text: "Remove")
        } else {
            cell.addItem.setupButton(isTapped: true, text: "Add")
        }
        
        cell.cellDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func didAddUpsell(_ tag: Int) {
        checkItem(tag: tag)
    }
    
    func setPrice() {
        var price = trailer.total ?? 0.0
        for tag in selectedUpsellTags {
            let id = trailerResponse.upsellItemsList?[tag].id ?? ""
            let qty : Double = Double(upsellQunatity[id] ?? 0)
            let subPrice = trailerResponse.upsellItemsList?[tag].totalCharges?.total?.stringvalue
            price += Double(subPrice!)! * qty
            price = price.rounded()
        }
        self.trailerPrice.text = String(price) + " AUD"
    }
    
    func checkItem(tag: Int) {
        var added = false
        let key = trailerResponse.upsellItemsList?[tag].id ?? ""
        for i in 0..<selectedUpsellTags.count {
            if(selectedUpsellTags[i] == tag) {
                selectedUpsellTags.remove(at: i)
                added = true
                setPrice()
                self.upsellTable.reloadData()
                self.upsellQunatity[key] = nil
                break
            }
        }
        
        if(!added) {
            showPicker(id: key)
            selectedUpsellTags.append(tag)
        }
    }
    
    func showPicker(id: String) {
        let actionSheet = UIAlertController(title: "\n\n\n\n\n\n\n Select Quantity", message: "How many do you want?", preferredStyle: .actionSheet)
        
        let picker = UIPickerView(frame: CGRect(x: 10, y: 10, width: actionSheet.view.bounds.size.width - 40, height: 120))
        
        
        actionSheet.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            let quantity = picker.selectedRow(inComponent: 0) + 1
            self.upsellQunatity[id] = quantity
            self.setPrice()
            self.upsellTable.reloadData()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.view.addSubview(picker)
        picker.delegate = self
        picker.dataSource = self
        present(actionSheet, animated: true)
    }
    
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: false)
    }
}

extension TrailerDetailsViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}

extension TrailerDetailsViewController : licenseeDelegate {
    func didGetLicenseeDetails(licensee: LicenseeObject) {
        self.licenseeDetails = licensee
    }
}



extension Double {
    var stringvalue : String{
        return String(self)
    }
}
