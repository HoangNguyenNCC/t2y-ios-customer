//
//  addressModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 23/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct Address : Codable {
    var addressModel : AddressModel
    var addressRequest : AddressRequest
}

struct AddressModel : Codable {
    var house: String?
    var landmark: String?
    var locality: String?
    var area: String?
}

struct AddressRequest : Codable {
    var country: String?
    var text: String?
    var pincode: String?
    var coordinates : [Double]?
    
    
    var dictionaryRepresentation: [String: String] {
        return [
            "reqBody[address][country]" : country ?? "",
            "reqBody[address][text]" : text ?? "",
            "reqBody[address][pincode]" : pincode ?? "",
            "reqBody[address][coordinates][0]" : String(coordinates?.first ?? 0.0),
            "reqBody[address][coordinates][1]" : String(coordinates?.last ?? 0.0)
        ]
    }
    
    var lat : String{
        return "\(coordinates?.first ?? 0.0)"
    }
    
    var lon : String{
        return "\(coordinates?.last ?? 0.0)"
    }
}

