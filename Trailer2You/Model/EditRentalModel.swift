//
//  EditRentalModel.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 19/08/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation


struct EditRentalModel {
    var type: rentalEditType
    var bookingID: String
    var rentalID: String
    var startDate: String
    var endDate: String
}

struct RescheduleResponse : Codable {
    var actionRequired : String?
    var booking : NewBooking?
    var priceDiff : Double?
    var message : String?
    var stripeClientSecret : String?
    var success : Bool?
}

struct NewBooking : Codable {
    var _id : String?
    var bookingType : String?
    var cancellationCharges : Double?
    var customerLocation : Location?
    var dlrCharges : Double?
    var doChargeDLR : Bool?
    var endDate : String?
    var lateFeePerDay : Double?
    var startDate : String? 
    var taxes : Double?
    var trailerId : String?
    var upsellItemIds : [String]?
    var charges : ChargesResponseModel?
}
