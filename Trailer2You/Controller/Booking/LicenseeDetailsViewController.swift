//
//  LicenseeDetailsViewController.swift
//  Trailer2You
//
//  Created by Pranav Karnani on 22/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import ProgressHUD
import MapKit

protocol licenseeDelegate: class {
    func didGetLicenseeDetails(licensee: LicenseeObject)
}

class LicenseeDetailsViewController: UIViewController {
    
    var licenseeId = ""
    var trailerName = ""
    var licenseeDetails = LicenseeObject()
    var licenseePresent = false
    var rentalItems = [RentalItem]()
    weak var delegate: licenseeDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var operatingView: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var licenseeHeadline: UILabel!
    @IBOutlet weak var licenseeCard: UIView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var ownerAddress: UILabel!
    @IBOutlet weak var ownerImage: UIImageView!
    @IBOutlet weak var ownerName2: UILabel!
    @IBOutlet weak var verifiedField: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var workingDays: UILabel!
    @IBOutlet weak var otherView: UIView!
    @IBOutlet weak var workingHours: UILabel!
    @IBOutlet weak var trailerCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.alpha = 0
        initialSetup()
        self.trailerCollection.dataSource = self
        self.trailerCollection.delegate = self
        
        overrideUserInterfaceStyle = .light
        map.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !licenseePresent || (self.licenseeDetails.name == nil){
        ProgressHUD.show("Fetching Licensee Details", interaction: true)
        ProgressHUD.animationType = .multipleCircleScaleRipple
        ProgressHUD.colorAnimation = .primary
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ProgressHUD.dismiss()
    }
    
    func initialSetup(){
        if licenseePresent{
            self.mapLicenseeDetails()
            self.setupMap()
            self.scrollView.alpha = 1
            self.rentalItems = licenseeDetails.rentalItems ?? []
        }else{
            getLicenseeDetails()
        }
    }
    
    func getLicenseeDetails()  {
        
            ServiceController.shared.getLicenseeDetails(withLicenseeId: licenseeId) { (success, licensee, error) in
                if(success) {
                    self.delegate?.didGetLicenseeDetails(licensee: licensee)
                    self.licenseeDetails = licensee
                    self.rentalItems = licensee.rentalItems!
                    DispatchQueue.main.async {
                        self.setupMap()
                        ProgressHUD.dismiss()
                        self.mapLicenseeDetails()
                        self.scrollView.alpha = 1
                    }
                }
                else {
                    ProgressHUD.showError(error.errors?.first ?? "Error", image: nil, interaction: true)
                }
            }
        
    }
    
    func mapLicenseeDetails() {
        businessName.text = licenseeDetails.name
        licenseeHeadline.text = trailerName
        ownerImage.kf.setImage(with: URL(string: licenseeDetails.ownerPhoto?.data ?? ""))
        ownerImage.contentMode = .scaleAspectFill
        businessImage?.kf.setImage(with: URL(string: licenseeDetails.logo?.data ?? ""))
        businessImage.contentMode = .scaleAspectFill
        ownerName.text = licenseeDetails.ownerName
        ownerName2.text = licenseeDetails.ownerName
        rating.text = "\(licenseeDetails.rating  ?? 0)/5"
        if licenseeDetails.proofOfIncorporationVerified ?? false {
            verifiedField.text = "Verified"
            verifiedField.textColor = .systemGreen
        } else {
            verifiedField.text = "Not Verified"
            verifiedField.textColor = .systemRed
        }
        workingDays.text = sortDays(days: licenseeDetails.workingDays ?? [String]())
        ownerAddress.text = String(licenseeDetails.address?.text?.split(separator: " ").last ?? "")
        workingHours.text = licenseeDetails.workingHours
        rentalItems = (rentalItems.filter({ (item) -> Bool in
            return item.rentalItemType! == .trailer
        }))
        self.trailerCollection.reloadData()
    }
    
    func sortDays(days: [String]) -> String {
        let newDays = days.map({ (s) -> String in
            return s.lowercased()
        })
        
        if newDays.contains("mon") && newDays.contains("tue") && newDays.contains("wed") && newDays.contains("thu") && newDays.contains("fri") {
            return "Weekdays"
        }
        if newDays.contains("sat") && newDays.contains("sun") {
            return "Weekends"
        }
        if newDays.count == 7 {
            return "All days"
        }
        else {
            var dayString = ""
            for day in days {
                dayString += day
                dayString += ", "
            }
            return String(dayString.dropLast(2))
        }
    }
    
    override func viewDidLayoutSubviews() {
        operatingView.makeBordered()
        operatingView.layer.cornerRadius = 12
        ownerImage.layer.cornerRadius = 25
        businessImage.layer.cornerRadius = 20
        otherView.makeBordered()
        otherView.layer.cornerRadius = 12
    }
    
    func setupMap() {
        centerMapOnLocation(CLLocation(latitude: licenseeDetails.address?.coordinates?[0] ?? -33.81, longitude: licenseeDetails.address?.coordinates?[1] ?? 151.13), mapView: map)
    }
    
    func centerMapOnLocation(_ location: CLLocation, mapView: MKMapView) {
        let regionRadius: CLLocationDistance = 1000
        
        let circle = MKCircle(center: location.coordinate, radius: regionRadius)
        mapView.addOverlay(circle)
        mapView.setNeedsDisplay()
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 5.0, longitudinalMeters: regionRadius * 5.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let trailerDetail = segue.destination as? BookedTrailerDetailsViewController{
            trailerDetail.type = .licensee
            trailerDetail.booking = sender as? String
        }
    }
}

extension LicenseeDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rentalItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trailerCell", for: indexPath) as! TrailerCell
        cell.itemImage.kf.setImage(with: URL(string: rentalItems[indexPath.item].photo?.first?.data ?? ""))
        cell.itemImage.makeBordered()
        cell.itemImage.layer.cornerRadius = 8
        cell.itemName.text = rentalItems[indexPath.item].name?.uppercased() ?? ""
        cell.itemPrice.text = (rentalItems[indexPath.item].price?.door2Door) ?? ""
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = rentalItems[indexPath.item]
        let id = item.id ?? ""
        if item.rentalItemType == RentalItemType.trailer{
        self.performSegue(withIdentifier: "licenseetrailer", sender: id)
        }
    }
}

extension LicenseeDetailsViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circelOverLay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(circle: circelOverLay)
        circleRenderer.lineWidth = 2
        circleRenderer.strokeColor = .primary
        circleRenderer.fillColor = UIColor.primary.withAlphaComponent(0.3)
        return circleRenderer
    }
}
