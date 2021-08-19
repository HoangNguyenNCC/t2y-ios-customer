//
//  SignupViewController+DataDelegates.swift
//  Trailer2You
//
//  Created by Aritro Paul on 23/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit

extension SignupViewController : addressDelegate, DLDelegate {
    
    func returnDLData(License: DriverLicense) {
        self.license = License
        self.licenseData = Data(base64Encoded: License.scan?.data ?? "") ?? Data()
        DLTextField.text = License.card
    }
    
    func didEnterAddress(address: Address) {
        self.addressCore = address.addressRequest
        addressTextField.text = address.addressRequest.text
    }
}
