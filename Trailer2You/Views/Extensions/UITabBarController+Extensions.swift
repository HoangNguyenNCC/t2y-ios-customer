//
//  UITabBarController+Extensions.swift
//  Trailer2You
//
//  Created by Aritro Paul on 10/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit

extension UITabBarController {
    func cleanTitles() {
        guard let items = self.tabBar.items else {
            return
        }
        for item in items {
            item.title = ""
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }
}
