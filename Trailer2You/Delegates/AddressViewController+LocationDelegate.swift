//
//  SignupViewController+LocationDelegate.swift
//  Trailer2You
//
//  Created by Aritro Paul on 23/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

extension AddressViewController : CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate  {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.shouldUpdateLocation {
           let userLocation:CLLocation = locations[0] as CLLocation
           print("user latitude = \(userLocation.coordinate.latitude)")
           print("user longitude = \(userLocation.coordinate.longitude)")
       // self.addressCore.coordinates = [userLocation.coordinate.latitude, userLocation.coordinate.longitude]
        }
    }
 
    func getAddress(location: CLLocation){

        let geoCoder = CLGeocoder()

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if let locality = placeMark.locality {
                self.localityLabel.text = locality
            }
            if let state = placeMark.administrativeArea, let country = placeMark.country, let pincode = placeMark.postalCode {
                self.stateAndCountryLabel.text = "\(state), \(country)"
                
                if self.landmarkTextField.text == "" {
                    let components = self.addressCore.text?.components(separatedBy: ", ").dropLast(3).dropFirst()
                    self.landmarkTextField.text = String(components?.joined(separator: ", ") ?? "")
                }
                
                self.addressModel = AddressModel(house: "", landmark: "", locality: placeMark.locality, area: placeMark.subLocality)
                
                self.addressCore.country = country
                self.addressCore.pincode = pincode
            }


        })

    }
    
}
