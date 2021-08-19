//
//  SearchModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 23/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct SearchResponse : Codable {
    var success : Bool?
    var message: String?
    var trailers : [TrailerResult]?
    var errorsList: [String]?
}

struct TrailerResult : Codable {
    var rentalItemId: String?
    var name: String?
    var type: String?
    var price: String?
    var photo: [Photo]?
    var licenseeId: String?
    var licenseeName: String?
    var licenseeDistance: String?
    var rating: Int?
    var rentalItemType: String?
    var upsellItems: [UpsellItemResult]?
}

struct BookingModel : Codable {
    var dates: [String]?
    var times: [String]?
    var delivery: String?
    var id: String?
    var address: AddressRequest?
}
