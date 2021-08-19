//
//  Payments.swift
//  Trailer2You
//
//  Created by Pranav Karnani on 28/03/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation

protocol PaymentDelegate: class {
    func paymentComplete(submissionID: String)
    func paymentFailed(errorCode: String)
}

class Payments {
    static weak var delegate : PaymentDelegate?
}
