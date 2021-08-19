//
//  FilterModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 22/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

enum DeliveryMethod : String {
    case pickup
    case door2door
}

struct FilterItems : Codable {
    var name: String?
    var code: String?
    var checked: Bool?
}

struct Filters : Codable {
    var trailerTypesList: [FilterItems]?
    var upsellItemTypesList: [FilterItems]?
    var trailerModelList : [FilterItems]?
}

struct FilterResponse : Codable {
    var success: Bool?
    var message: String?
    var filtersObj: Filters?
    var errorsList: [String]?
}
