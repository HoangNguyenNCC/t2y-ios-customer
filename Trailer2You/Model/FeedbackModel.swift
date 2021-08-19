//
//  FeedbackModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 08/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

struct FeedbackRequest : Codable {
    var rating: RatingRequest?
    var review: ReviewRequest?
}

struct RatingRequest : Codable {
    var itemType: RatingItem
    var itemId: String?
    var ratedByUserId: String?
    var ratingValue: Int?
}

struct ReviewRequest : Codable {
    var trailerId: String?
    var reviewedByUserId: String?
    var reviewText: String?
}

enum RatingItem : String, Codable {
    case trailer = "trailer"
    case upsell = "upsellitem"
}

struct FeedbackResponse : Codable {
    var success: Bool?
    var message: String?
    var errorsList: [String]?
}

struct SignupResponse : Codable {
    var success: Int?
    var message: String?
    var errorsList: [String]?
}
