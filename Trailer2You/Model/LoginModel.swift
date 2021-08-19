//
//  LoginModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 13/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct LoginRequest : Codable {
    var email: String?
    var password: String?
}

struct LoginResponse : Codable {
    var success: Bool?
    var message: String?
    var dataObj: DataObj?
    var errorsList: [String]?
}

struct DataObj: Codable {
    var userObj: User?
    var token: String?
}

struct OTPStatus: Codable {
    var mobile: String?
    var country: String?
}
