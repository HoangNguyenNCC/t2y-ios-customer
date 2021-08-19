//
//  RatingsViewController.swift
//  Trailer2You
//
//  Created by Aritro Paul on 08/04/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import SPAlert

protocol SkipDelegate : class {
    func didSkip()
}

class RatingsViewController: UIViewController {
    
    @IBOutlet weak var ratingsView: UIStackView!
    @IBOutlet weak var reviewTextField: UITextView!
    @IBOutlet weak var skipFeedbackButton: UIButton!
    @IBOutlet weak var submitFeedbackButton: UIButton!
    @IBOutlet weak var licenseeRatingsView: UIStackView!
    
    var ratings : Int = 0
    var licenseeratings : Int = 0
    var invoiceId = ""
    weak var delegate : SkipDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        reviewTextField.delegate = self
        reviewTextField.text = "Write a review"
        reviewTextField.textColor = .secondaryLabel
        setupRatings()
        setupLicenseeRatings()
        reviewTextField.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    
    func setupRatings() {
        for star in ratingsView.subviews {
            star.tintColor = .systemGray5
        }
        for index in ratingsView.subviews.indices {
            let star = ratingsView.subviews[index]
            star.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(tappedStar(sender: )))
            star.tag = index
            star.addGestureRecognizer(tapGes)
        }
    }
    
    func setupLicenseeRatings() {
        for star in licenseeRatingsView.subviews {
            star.tintColor = .systemGray5
        }
        for index in licenseeRatingsView.subviews.indices {
            let star = licenseeRatingsView.subviews[index]
            star.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(licenseetappedStar(sender: )))
            star.tag = index
            star.addGestureRecognizer(tapGes)
        }
    }
    
    @objc func tappedStar(sender: UITapGestureRecognizer) {
        rating(stars: 0, stack: ratingsView)
        let cardNumber = sender.view?.tag ?? -1
        ratings = cardNumber + 1
        rating(stars: ratings, stack: ratingsView)
    }
    
    @objc func licenseetappedStar(sender: UITapGestureRecognizer) {
        rating(stars: 0, stack: licenseeRatingsView)
        let cardNumber = sender.view?.tag ?? -1
        licenseeratings = cardNumber + 1
        rating(stars: licenseeratings, stack: licenseeRatingsView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        submitFeedbackButton.layer.cornerRadius = submitFeedbackButton.frame.height/2
        reviewTextField.layer.borderWidth = 1
        reviewTextField.layer.borderColor = UIColor.systemGray5.cgColor
        reviewTextField.layer.cornerRadius = 8
        reviewTextField.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        ServiceController.shared.rateTrailer(invoiceId: invoiceId, rating: ratings, review: reviewTextField.text,licensee: licenseeratings) { (success) in
            if success{
                DispatchQueue.main.async {
                    SPAlert.present(title: "Thank you!", preset: .heart)
                    self.dismiss(animated: true) {
                        self.delegate?.didSkip()
                    }
                }
            } else {
                self.dismiss(animated: true) {
                    self.delegate?.didSkip()
                }            }
        }
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        self.delegate?.didSkip()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func rating(stars: Int,stack:UIStackView) {
        switch stars {
        case 1: stack.subviews[0].tintColor = .systemOrange
        case 2:
            stack.subviews[0].tintColor = .systemOrange
            stack.subviews[1].tintColor = .systemOrange
        case 3:
            stack.subviews[0].tintColor = .systemOrange
            stack.subviews[1].tintColor = .systemOrange
            stack.subviews[2].tintColor = .systemOrange
        case 4:
            stack.subviews[0].tintColor = .systemOrange
            stack.subviews[1].tintColor = .systemOrange
            stack.subviews[2].tintColor = .systemOrange
            stack.subviews[3].tintColor = .systemOrange
        case 5:
            stack.subviews[0].tintColor = .systemOrange
            stack.subviews[1].tintColor = .systemOrange
            stack.subviews[2].tintColor = .systemOrange
            stack.subviews[3].tintColor = .systemOrange
            stack.subviews[4].tintColor = .systemOrange
        case 0:
            stack.subviews[0].tintColor = .systemGray5
            stack.subviews[1].tintColor = .systemGray5
            stack.subviews[2].tintColor = .systemGray5
            stack.subviews[3].tintColor = .systemGray5
            stack.subviews[4].tintColor = .systemGray5
            
        default: break
        }
    }
    
}

extension RatingsViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.secondaryLabel {
            textView.text = ""
            textView.textColor = .black
        }
        textView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a review"
            textView.textColor = UIColor.secondaryLabel
            textView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
    }
}
