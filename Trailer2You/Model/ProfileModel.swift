//
//  ProfileMode.swift
//  Trailer2You
//
//  Created by Aritro Paul on 28/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct Profile : Codable{
    var isMobileVerified: Bool?
    var isEmailVerified: Bool?
    var email: String?
    var mobile: String?
    var address: AddressRequest?
    var name: String?
    var driverLicense: DriverLicense?
    var photo: Photo?
    var dob: String?
    var createdAt: String?
}

struct ProfileResponse : Codable {
    var success: Bool?
    var message: String?
    var userObj: User?
    var errorsList: [String]?
}

struct Licensee: Codable {
    var success: Bool?
    var message: String?
    var licenseeObj: LicenseeObject?
    var errorsList: [String]?
}

struct LicenseeObject: Codable {
    var id, name, email, mobile: String?
    var address: AddressRequest?
    var locations: [AddressRequest]?
    var logo: Photo?
    var rating: Int?
    var ownerName: String?
    var ownerPhoto: Photo?
    var workingDays: [String]?
    var workingHours: String?
    var rentalItems: [RentalItem]?
    var proofOfIncorporationVerified: Bool?
}

// MARK: - RentalItem
struct RentalItem: Codable {
    var id, name, type: String?
    var rentalItemType: RentalItemType?
    var photo: [Photo]?
    var price: PriceType?

    enum CodingKeys: String, CodingKey {
        case id, name
        case type, rentalItemType, photo
        case price
    }
}

struct PriceType: Codable {
    var pickUp: String?
    var door2Door: String?
}

enum RentalItemType: String, Codable {
    case trailer = "trailer"
    case upsellitem = "upsellitem"
}

