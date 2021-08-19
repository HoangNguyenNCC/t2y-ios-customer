//
//  SuccessViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 20/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    
    var login : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let identifier = self.login ? "unwindToLogin" : "unwindToEditProfile"
            self.performSegue(withIdentifier: identifier, sender: Any?.self)
        }
    }
}
