//
//  TrailerDetailsModel.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 15/06/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct TrailerDetailsModel : Codable {
    var success: Bool?
    var message: String?
    var trailerObj : TrailerDetailObject?
    var errorsList: [String]?
}

struct TrailerDetailObject : Codable {
    
    var features: [String?]?
    var photos: [Photo?]?
    var availability: Bool
    var id: String?
    var name: String?
    var type: String?
    var description: String?
    var size: String?
    var capacity: String?
    var age: Int
    var tare: String?
    var licenseeId: String?
    var rating: Int?
    var rentalCharges: RentalCharges
    var price: String?
    var rentalsList: [RentalTimeDetails]?
    var insured : Bool?
    var serviced : Bool?
}

struct RentalCharges: Codable{
    var pickUp: [RentalChargeDetails]
    var door2Door: [RentalChargeDetails]
}

struct RentalChargeDetails : Codable{
    var duration: Int?
    var charges: Int?
}

struct RentalTimeDetails : Codable{
    var start: String?
    var end: String
}
