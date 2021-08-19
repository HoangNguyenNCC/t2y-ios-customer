//
//  UITextField+Extensions.swift
//  Trailer2You
//
//  Created by Aritro Paul on 02/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func setPadding(){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.size.height))
        self.leftView = paddingView
        self.rightView = paddingView
        self.leftViewMode = .always
        self.rightViewMode = .always
    }
    
    func addIcon(iconName: String) {
        let iconView = UIImageView(frame:
                       CGRect(x: 10, y: 10, width: 20, height: 20))
        iconView.contentMode = .scaleAspectFill
        iconView.image = UIImage(systemName: iconName)
        let iconContainerView: UIView = UIView(frame:
                       CGRect(x: 20, y: 0, width: 45, height: 40))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
    
    func addCardIcon(card: String) {
        let iconView = UIImageView(frame:
                       CGRect(x: 10, y: 10, width: 30, height: 20))
        iconView.contentMode = .scaleAspectFill
        iconView.image = UIImage(named: card)
        let iconContainerView: UIView = UIView(frame:
                       CGRect(x: 20, y: 0, width: 50, height: 40))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
    
    func setCharacterSpacing(characterSpacing: CGFloat = 0.0) {

        guard let labelText = text else { return }

        let attributedString: NSMutableAttributedString
        if let labelAttributedText = attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // Character spacing attribute
    attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSMakeRange(0, attributedString.length))

        attributedText = attributedString
    }
}
