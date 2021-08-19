//
//  InvoiceDisplayModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 27/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct InvoiceDisplayItem : Codable {
    var id : String?
    var name: String?
    var photo: Photo?
    var price: Double?
    var units: Int?
}
