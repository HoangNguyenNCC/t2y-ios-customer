//
//  TabBarController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 09/05/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindToHome( _ seg: UIStoryboardSegue) {
        selectedIndex = 0
    }
    
    @IBAction func unwindToNotifications( _ seg: UIStoryboardSegue) {
        selectedIndex = 1
    }

    @IBAction func unwindToProfile( _ seg: UIStoryboardSegue) {
        selectedIndex = 2
    }
    
}
