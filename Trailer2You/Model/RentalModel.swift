//
//  RentalModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 09/05/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct RentalResponse: Codable {
    var success: Bool?
    var message: String?
    var rentalObj: InvoiceObj?
    var errorsList: [String]?
}
