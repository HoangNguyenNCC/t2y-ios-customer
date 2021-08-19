//
//  DLModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 03/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct DriverLicense : Codable {
    var verified: Bool?
    var card: String?
    var accepted: Bool?
    var expiry: String?
    var state: String?
    var scan: Photo?
    
    var dictionaryRepresentation: [String: String] {
        return [
            "reqBody[driverLicense][card]" : card ?? "",
            "reqBody[driverLicense][expiry]" : expiry ?? "",
            "reqBody[driverLicense][state]" : state ?? "",
            "driverLicenseScan" : scan?.data ?? ""
        ]
    }
}
