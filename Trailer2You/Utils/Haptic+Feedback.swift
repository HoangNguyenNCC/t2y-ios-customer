//
//  Haptic+Feedback.swift
//  Trailer2You
//
//  Created by Aaryan Kothari on 24/06/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

/// `Better UX`

extension UIDevice {
    
    // Vibrates when any error occur like invalid password etc.
    static func invalidVibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(1102))
    }
    
    // For success login
    static func validVibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
