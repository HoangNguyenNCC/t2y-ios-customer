//
//  InvoiceModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 27/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

enum ItemType : String, Codable {
    case trailer
    case upsellitem
}

struct Payment : Codable {
    var trailerId : String
    var upsellItems: [upsellObject]
    var startDate: String
    var endDate : String
    var customerId : String
    var isPickup : Bool
    var customerLocation : Location
    var doChargeDLR: Bool
}

struct upsellObject : Codable {
    var id : String
    var quantity : Int
}


struct Invoice : Codable {
    var _id : String?
    var description : String?
    var licenseeId: String?
    var rentedItems: [RentedItem]?
    var rentalPeriod: RentalPeriod?
    var doChargeDLR: Bool?
    var isPickup: Bool?
    var pickUpLocation: Location?
    var dropOffLocation: Location?
    var revision : [Revision]?
}

extension InvoiceObj{
    var dateDetails : String{
        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone(abbreviation: "UTC")
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let startDate = dateformatter.date(from: self.revisions?.last?.start ?? "")
        let endDate = dateformatter.date(from: self.revisions?.last?.end ?? "")
        
        if let start = startDate, let end = endDate{
            dateformatter.timeZone = .current
            dateformatter.dateFormat = "dd MMM HH:mm"
            let startTime = dateformatter.string(from: start)
            let endTime = dateformatter.string(from: end)
            
            return startTime + " - " + endTime
        } else {
            return ""
        }
    }
}

struct RentedItem : Codable {
    var itemType: ItemType?
    var itemId: String?
    var units: Int?
    var itemName : String?
}

struct RentalPeriod : Codable {
    var start: String?
    var end: String?
}

struct Location : Codable {
    var text: String?
    var pincode: String?
    var coordinates: [Double]?
}


// MARK: - Empty
struct InvoiceGenerated: Codable {
    var success: Bool?
    var message: String?
    var invoiceObj: InvoiceObj?
    var errorsList: [String]?
}

// MARK: - InvoiceObj
struct InvoiceObj: Codable {
    var total: Double?
    var transactionAuthAmount, transactionActionAmount: Int?
    var isApproved: Int?
    var bookingId : String?
    var approvedBy, rentalStatus, id: String?
    var dropOffLocation: Location?
    var rentalPeriod: RentalPeriod?
    var invoiceObjDescription: String?
    var doChargeDLR: Bool?
    var pickUpLocation: Location?
    var licenseeID: String?
    var rentedItems: [RentedItemInvoice]?
    var bookedByUserID: String?
    var isPickUp: Bool?
    var totalCharges: InvoiceTotalCharges?
    var invoiceNumber: Int?
    var invoiceReference: String?
    var createdAt, updatedAt: String?
    var revisions : [Revision]?
    var v: Int?
    
    enum CodingKeys: String, CodingKey {
        case total, transactionAuthAmount, transactionActionAmount, isApproved, approvedBy, rentalStatus
        case id = "_id"
        case dropOffLocation, rentalPeriod, bookingId
        case invoiceObjDescription = "description"
        case doChargeDLR, pickUpLocation
        case licenseeID = "licenseeId"
        case rentedItems
        case bookedByUserID = "bookedByUserId"
        case isPickUp, totalCharges, invoiceNumber, invoiceReference
        case createdAt, updatedAt, revisions
        case v = "__v"
    }
    
    func totalTaxes()->Double{
        guard let revisions = revisions else { return 0.0 }
        
        let isCancel =  revisions.last?.revisionType == "cancellation"
        let charges = isCancel ? revisions.filter{ $0.charges != nil }.last?.charges : revisions.last?.charges
        return charges?.totalTaxes() ?? 0.0
    }
    
    func totalDlr()->Double{
        guard let revisions = revisions else { return 0.0 }
        let isCancel =  revisions.last?.revisionType == "cancellation"
        let charges = isCancel ? revisions.filter{ $0.charges != nil }.last?.charges : revisions.last?.charges
        return charges?.totalDlr() ?? 0.0
    }
    
}

struct Revision : Codable {
    var end : String?
    var start : String?
    var charges : ChargesResponseModel?
    var revisionType : String?
}

struct RentedItemInvoice: Codable {
    var units: Int?
    var id, itemType, itemID: String?
    var itemName : String?
    var itemPhoto : Photo?
    var totalCharges: InvoiceTotalCharges?
    
    enum CodingKeys: String, CodingKey {
        case units
        case id
        case itemType
        case itemID = "itemId"
        case totalCharges
        case itemPhoto,itemName
    }
}

struct ReviewData : Codable {
    let invoice : InvoiceObj
    let licensee : LicenseeObject
    let trailer : TrailerObject
}

struct InvoiceTotalCharges: Codable {
    var total,taxes: Double?
    var rentalCharges: Int?
    var dlrCharges: Double?
    var t2YCommission, discount, lateFees: Int?
    var cancellationCharges: Int?
    var id : String?
    
    enum CodingKeys: String, CodingKey {
        case total, rentalCharges, dlrCharges,taxes
        case t2YCommission = "t2yCommission"
        case discount, lateFees, cancellationCharges
        case id
    }
}

