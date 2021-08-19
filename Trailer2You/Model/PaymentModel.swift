//
//  Payment.swift
//  Trailer2You
//
//  Created by Aritro Paul on 11/05/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct SetupPaymentResponse : Codable {
    var stripePaymentIntentId: String?
    var stripeClientSecret: String?
    var success : Bool?
    var message : String?
}
