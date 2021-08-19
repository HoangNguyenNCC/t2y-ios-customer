//
//  locationStartResponseModel.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 17/06/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import MapKit

struct locationStartResponseModel : Codable{
    var success : Bool?
    var message : String?
    var locationObj : LocationObj?
    var errorsList: [String]?

    var coordinates : CLLocationCoordinate2D {
        var lon = self.locationObj?.dropOffLocation?.location?.coordinates.first ?? 0.0
        var lat = self.locationObj?.dropOffLocation?.location?.coordinates.last ?? 0.0

        var coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)

        return coord
    }
}

struct LocationObj : Codable {
    var dropOffLocation : DropOffLocation?
    var pickUpLocation :  PickUpLocation?
}

struct DropOffLocation : Codable {
    var text : String?
    var pincode : String?
    var location: StartLocation?
}

struct StartLocation : Codable {
    var type : String
    var coordinates : [Double]
}

struct PickUpLocation: Codable {
    
}
