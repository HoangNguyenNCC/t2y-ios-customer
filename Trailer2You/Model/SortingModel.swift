//
//  SortingModel.swift
//  Trailer2You
//
//  Created by Aritro Paul on 22/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

enum SortingType : String {
    case ascending
    case descending
    case five
    case fourPlus
    case threePlus
}

enum Criteria : String {
    case pricing
    case distance
    case rating
}

struct Sort {
    var crit: Criteria?
    var type: SortingType?
}
