//
//  PaymentInputViewController+PayCardsDelegate.swift
//  Trailer2You
//
//  Created by Aritro Paul on 13/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit
import PayCardsRecognizer

extension PaymentInputViewController : PayCardsRecognizerPlatformDelegate {
    
    func payCardsRecognizer(_ payCardsRecognizer: PayCardsRecognizer, didRecognize result: PayCardsRecognizerResult) {
        payCardsRecognizer.stopCamera()
        print(result)
        
    }
    
}
