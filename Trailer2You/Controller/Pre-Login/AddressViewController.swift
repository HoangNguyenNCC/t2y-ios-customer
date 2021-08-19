//
//  AddressViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 22/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import MapKit
import SPAlert
import CoreLocation

protocol addressDelegate: class {
    func didEnterAddress(address: Address)
}



class AddressViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var localityLabel: UILabel!
    @IBOutlet weak var stateAndCountryLabel: UILabel!
    @IBOutlet weak var houseNumberTextField: UITextField!
    @IBOutlet weak var landmarkTextField: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressSearchField: UITextField!
    
    
    //MARK: Variables
    var locationManager:CLLocationManager!
    weak var delegate: addressDelegate?
    var frame = CGRect()
    var fromDelegate = false
    var addressCore = AddressRequest()
    var addressModel = AddressModel()
    var isBooking = false
    var booking = BookingModel()
    var shouldUpdateLocation = true
    var selectedtrailer : String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        /// Icons
        houseNumberTextField.addIcon(iconName: "number.circle.fill")
        landmarkTextField.addIcon(iconName: "mappin.and.ellipse")
        addressSearchField.addIcon(iconName: "magnifyingglass")
        
        
        /// Corner Radii
        houseNumberTextField.layer.cornerRadius = 8
        landmarkTextField.layer.cornerRadius = 8
        addressSearchField.layer.cornerRadius = 8
        backView.layer.cornerRadius = 8
        
        /// View
        self.isModalInPresentation = true
        frame = self.view.frame
        
        /// Address
        (addressCore.text != nil) ? LocationPresent() : setupMap()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.isOpaque = false
        view.layer.backgroundColor = UIColor.clear.cgColor
        view.layer.isOpaque = false
        self.shouldUpdateLocation = true
        //setupMap()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.shouldUpdateLocation = false
    }
    
    
    @IBAction func longPressMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended{
            let tapLocation = sender.location(in: mapView)
            let coordinate = self.mapView.convert(tapLocation, toCoordinateFrom: self.mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            print("LOCATION IS:",location)
            locationToText(location) { (result) in
                var address = result
                address.coordinates = [coordinate.latitude,coordinate.longitude]
                print("COORDINATES ARE: ",coordinate)
                self.booking.address = address
                self.addressCore = address
                self.setupPin(address: address)
            }
        }
    }
    
    func LocationPresent(){
        let house = addressCore.text?.split(separator: ",")[0]
        let lat = addressCore.coordinates?[0] ?? -33.81
        let long = addressCore.coordinates?[1] ?? 151.2
        setupPin(address: addressCore)
        houseNumberTextField.text = String(house ?? "")
        let location = CLLocation(latitude: lat, longitude: long)
        getAddress(location: location)
    }
    
    
    
    func setupMap() {
        mapView.makeCard()
        mapView.layer.cornerRadius = 12
        mapView.delegate = self
        mapView.showsUserLocation = true
        determineMyCurrentLocation()
    }
    
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            let viewRegion = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(viewRegion, animated: true)
           // getAddress(location: locationManager.location ?? CLLocation())
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: 0, y: -30, width: self.frame.width, height: self.frame.height)
        }
    }
    
    
    @IBAction func addAddressTapped(_ sender: Any) {
        if validate() {
        if let house = houseNumberTextField.text, let landmark = landmarkTextField.text, let locality = localityLabel.text, let area = stateAndCountryLabel.text {
            if fromDelegate {
                let addressString = "\(house), \(landmark)"
                addressCore.text = addressString
            }
            else {
                let addressString = "\(house), \(landmark), \(locality), \(area)"
                addressCore.text = addressString
            }
            if let parentVC = self.presentingViewController {
                if parentVC.isKind(of: UITabBarController.self) {
                    savedAddress = addressCore
                    self.booking.address = addressCore
                    self.performSegue(withIdentifier: "dates", sender: Any?.self)
                }
                else {
                    let address = Address(addressModel: addressModel, addressRequest: addressCore)
                    self.delegate?.didEnterAddress(address: address)
                    self.dismiss(animated: true, completion: nil)
                 }
              }
           }
        }
    }
    
    func validate()->Bool{
        if houseNumberTextField.text == ""{
            SPAlert.present(title: "Enter House Number", image: #imageLiteral(resourceName: "house"), haptic: .error)
            return false
        }
        if landmarkTextField.text == ""{
            SPAlert.present(title: "Enter Location", message: "You can search above or long press on the map", image: #imageLiteral(resourceName: "house"), haptic: .error)
            return false
        }
        if let _ = localityLabel.text, let _ = stateAndCountryLabel.text {
            return true
        } else {
            SPAlert.present(message: "Please try again", haptic: .warning)
            return false
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let completionVC = segue.destination as? AddressFinderViewController {
            completionVC.delegate = self
        }
        if let vc = segue.destination as? DatesViewController {
            print(booking)
            vc.booking = booking
            vc.address = self.addressModel.area ?? self.addressModel.locality ?? "Australia"
            if let name = self.selectedtrailer {
                vc.selectedtrailer = name
            }
        }
    }
}

extension AddressViewController : addressCompletionDelegate {
    func didCompleteAddress(address: AddressRequest) {
        self.addressCore = address
        fromDelegate = true
        setupPin(address: address)
    }
    
    func setupPin(address: AddressRequest) {
        landmarkTextField.text = address.text
        let location = CLLocationCoordinate2D(latitude: address.coordinates?[0] ?? 0.0, longitude: address.coordinates?[1] ?? 0.0)
        let annotation = MKPointAnnotation()
        annotation.title = String(address.text?.split(separator: ",")[0] ?? "")
        annotation.coordinate =  location
        mapView.removeAnnotations(self.mapView.annotations)
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        getAddress(location: CLLocation(latitude: location.latitude, longitude: location.longitude))
    }
    
}

extension AddressViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == addressSearchField {
            textField.resignFirstResponder()
            self.performSegue(withIdentifier: "completion", sender: Any?.self)
        }
    }
}

extension AddressViewController{
    func locationToText(_ location: CLLocation,completion: @escaping (AddressRequest)-> ()){
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {  return }
            guard let placemark = placemarks?.first else { return }
            if
                let country = placemark.country,
                let pincode = placemark.postalCode {
                self.addressModel = AddressModel(house: "", landmark: "", locality: placemark.locality, area: placemark.subLocality)
                let address = AddressRequest(country: country, text: placemark.stringValue, pincode: pincode, coordinates: [])
                completion(address)
            }
        }
    }
}

extension CLPlacemark {
    var stringValue : String{
        let address = [self.thoroughfare ?? ""
        ,self.subLocality ?? ""
        ,self.locality ?? ""
        ,self.administrativeArea ?? ""
        ,self.postalCode ?? ""
        ,self.country ?? ""]
        
        var text = ""
        for i in address {
            if i != ""{
            text += i + ", "
            }
        }
        
        return text
    }
}
