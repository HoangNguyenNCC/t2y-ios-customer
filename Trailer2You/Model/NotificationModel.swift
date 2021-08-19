//
//  NotificationModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 07/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct NotificationResponse : Codable {
    var success: Bool?
    var message: String?
    var remindersList: [Reminder]?
    var errorsList: [String]?
}

struct Reminder : Codable {
    var rentedItems: [ReminderRentedItem]
    var invoiceId: String?
    var licenseeName: String?
    var reminderType: String?
    var reminderText: String?
    var isApproved: Int?
    var isTracking: Bool?
    var status : String?
}

struct ReminderRentedItem : Codable {
    var itemType : String?
    var itemId: String?
    var rentedItemType: String?
    var itemName: String?
    var itemPhoto: Photo?
}

enum ReminderType : String{
    case reminders
    case all
    case rating
    
    var title : String{
        switch self {
        case .reminders:
            return "Reminders and Notifications"
        case .all:
            return "Reminders and Notifications"
        case .rating:
            return "Ratings and Reviews"
        }
    }
    
    var subTitle : String{
        switch self {
        case .reminders:
            return "D O N ' T   B L I N K"
        case .all:
            return "Y O U R   O R D E R S"
        case .rating:
            return "G I V E   F E E D B A C K"
        }
    }
}
