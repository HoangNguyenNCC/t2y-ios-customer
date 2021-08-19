//
//  SignupModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 13/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct SignupRequest : Codable {
    var email: String?
    var password: String?
    var name: String?
    var mobile: String?
    var address: AddressRequest?
    var dob: String?
    var driverLicense: DriverLicense?
    var creditCard: CreditCard?
}
