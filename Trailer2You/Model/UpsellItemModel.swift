//
//  UpsellItemModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 11/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct UpsellItemResponse : Codable {
    var success: Bool?
    var message: String?
    var upsellItemsList: [UpsellItem]?
    var errorsList: [String]?
}

struct UpsellItem : Codable {
    var _id: String?
    var name: String?
    var licensee: String?
    var photo: String?
    var rating: Int?
    var price: String?
}


struct UpsellItemResult : Codable {
    var rentalItemId: String?
    var name: String?
    var type: String?
    var price: String?
    var photo: String?
    var licenseeId: String?
    var rentalItemType : RentalItemType?
    var availableQuantity: Int?
}
