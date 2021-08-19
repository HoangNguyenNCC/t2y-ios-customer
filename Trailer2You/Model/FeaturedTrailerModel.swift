//
//  FeaturedTrailerModel.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 16/06/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation


struct FeaturedTrailer : Codable{
    var _id: String?
    var name: String?
    var type: String?
    var description: String?
    var capacity : String?
    var features : [String]?
    var size : String?
    var tare : String?
    var photos : [Photo]?
}

struct FeaturedTrailerResponse : Codable {
    var success: Bool?
    var message: String?
    var trailers: [FeaturedTrailer]?
    var errorsList: [String]?
}
