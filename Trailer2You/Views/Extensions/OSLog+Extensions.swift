//
//  OSLog+Extensions.swift
//  Trailer2You
//
//  Created by Aritro Paul on 06/05/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import os

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let network = OSLog(subsystem: subsystem, category: "Network")
}
