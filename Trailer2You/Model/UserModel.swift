//
//  UserModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 13/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct User : Codable {
    var isMobileVerified: Bool?
    var isEmailVerified: Bool?
    var _id: String?
    var email: String?
    var mobile: String?
    var name: String?
    var address: AddressRequest?
    var dob: String?
    var driverLicense: DriverLicense?
    var photo: Photo?
    
    var dictionaryRepresentation: [String: String] {
        return [
            "reqBody[email]" : email ?? "",
            "reqBody[mobile]" : mobile ?? "",
            "reqBody[name]" : name ?? "",
            "reqBody[dob]" : dob ?? "",
            "photo" : ""
        ]
    }
}

struct UserResponse : Codable {
    var success: Bool?
    var message: String?
    var userObj: User?
    var errorsList: [String]?
}
