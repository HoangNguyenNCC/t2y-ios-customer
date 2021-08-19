//
//  TrailerModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 28/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct Trailer : Codable{
    var _id: String?
    var name: String?
    var licensee: String?
    var photo: Photo?
    var price: String?
    var rating: Int?
}

struct TrailerResponse : Codable {
    var success: Bool?
    var message: String?
    var trailersList: [Trailer]?
    var errorsList: [String]?
}

enum TrailersList {
    case featured
    case licensee
    case all
}

struct TrailerDetailResponse : Codable {
    var success: Bool?
    var message: String?
    var trailerObj: TrailerObject?
    var upsellItemsList: [UpsellItemsList]?
    var licenseeObj: LicenseeOverview?
    var errorsList: [String]?
}

struct LicenseeOverview: Codable {
    var licenseeId, licenseeName, ownerName: String?
}

struct TrailerObject: Codable {
    var features: [String]?
    var availability, isFeatured: Bool?
    var id, name, vin, type: String?
    var trailerObjDescription, size, capacity, tare: String?
    var age, dlrCharges: Int?
    var licenseeID: String?
    var photos: [Photo]?
    var createdAt, updatedAt: String?
    var v, rating: Int?
    var totalCharges: TotalCharges?
    var total: Double?
    var insured, serviced: Bool?
    var distance: String?

    enum CodingKeys: String, CodingKey {
        case features, availability, isFeatured
        case id = "_id"
        case name, vin, type
        case trailerObjDescription = "description"
        case size, capacity, tare, age, dlrCharges
        case licenseeID = "licenseeId"
        case photos, createdAt, updatedAt
        case v = "__v"
        case rating, totalCharges, total, insured, serviced, distance
    }
}

struct UpsellItemsList: Codable {
    var id, name, upsellItemsListDescription, type: String?
    var isAvailableForRent: Bool?
    var photo: [Photo]?
    var rating: Int?
    var insured, serviced: Bool?
    var totalCharges: TotalCharges?
    var total : Double?
    var distance: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case upsellItemsListDescription = "description"
        case type, isAvailableForRent, photo, rating, insured, serviced, totalCharges, total, distance
    }
}

struct TotalCharges: Codable {
    let total, rentalCharges, dlrCharges, t2YCommission: Double?
    let discount, lateFees: Double?

    enum CodingKeys: String, CodingKey {
        case total, rentalCharges, dlrCharges
        case t2YCommission = "t2yCommission"
        case discount, lateFees
    }
}
