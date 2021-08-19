//
//  UIView+Extensions.swift
//  Trailer2You
//
//  Created by Aritro Paul on 10/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func makeCard(){
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.1
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func makeBottomCard(){
        self.layer.shadowOffset = CGSize(width: 0, height: -8)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.1
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func makeTopCard(){
        self.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.1
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func makeBordered() {
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.tertiarySystemFill.cgColor
    }
    
    func makeRoundedCorners(usingCorners corners: UIRectCorner, cornerRadii: Int) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadii, height: cornerRadii))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path
        borderLayer.strokeColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1).cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 3
        borderLayer.frame = self.bounds
        self.layer.addSublayer(borderLayer)
        
    }
    
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension UIViewController {
    func showErrorAlert(title: String, subtitle: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showLoadingAlert(viewController: UIViewController, title: String) -> UIAlertController{
        let alert = UIAlertController(title: "\n\n\n\(title)", message: "", preferredStyle: .alert)
        let activity = UIActivityIndicatorView(style: .medium)
        activity.color = .label
        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(activity)
        let views = ["pending" : alert.view, "indicator" : activity]
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(30)-[indicator]-(60)-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: [], metrics: nil, views: views)
        alert.view.addConstraints(constraints)
        activity.startAnimating()
        viewController.present(alert, animated: true, completion: nil)
        return alert
    }
}
