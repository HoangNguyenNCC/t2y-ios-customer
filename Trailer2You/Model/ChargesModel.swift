//
//  ChargesModel.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 21/08/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct ChargesRequestModel : Codable {
    var trailerId : String
    var upsellItems : [upsellObject]
    var startDate : String
    var endDate : String
    var isPickup : Bool = false
}


struct ChargesResponseModel : Codable{
    var totalPayableAmount : Double?
    var trailerCharges : Charges?
    var upsellCharges : [upsellCharge]?
    
    func totalTaxes()->Double{
    
        var taxes = trailerCharges?.taxes ?? 0.0
           
        if let upsellTaxes = upsellCharges{
            let upsellTax = upsellTaxes.map { ($0.charges?.taxes ?? 0.0) * Double($0.quantity ?? 1)}.reduce(0, +)
               taxes += upsellTax
           }
           
           return taxes
       }
       
       func totalDlr()->Double{
           
           
           var damage = trailerCharges?.dlrCharges ?? 0.0

            if let upsellDlrs = upsellCharges{
                let upsellDlr = upsellDlrs.map { ($0.charges?.dlrCharges ?? 0.0) * Double($0.quantity ?? 1) }.reduce(0, +)
                damage += upsellDlr
            }
           
           return damage
       }
    
    func upsellBaseCharges()->[String:Double]{
        if let  upsell = self.upsellCharges {
            var charges = [String:Double]()
            for charge in upsell{
                charges[charge.id ?? ""] = (charge.charges?.rentalCharges ?? 0.0)
            }
            return charges
        } else {
            return [:]
        }
    }
    
}

struct upsellCharge : Codable {
    var charges : Charges?
    var id : String?
    var quantity : Int?
}

struct Charges : Codable {
    var total : Double?
    var rentalCharges : Double?
    var dlrCharges : Double?
    var t2yCommission : Double?
    var discount : Double?
    var lateFees : Double?
    var cancellationCharges : Double?
    var taxes : Double?
}

//{
//    "totalPayableAmount": 232.76,
//    "trailerCharges": {
//        "total": 232.76,
//        "rentalCharges": 184,
//        "dlrCharges": 27.6,
//        "t2yCommission": 0,
//        "discount": 0,
//        "lateFees": 0,
//        "cancellationCharges": 0,
//        "taxes": 21.16
//    },
//    "upsellCharges": {}
//}
