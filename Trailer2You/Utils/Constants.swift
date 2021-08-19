//
//  Constants.swift
//  Trailer2You
//
//  Created by Aritro Paul on 13/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit
import Just

var token = ""
var user = ""
var placeholderImage = "https://picsum.photos/200"
var savedAddress = AddressRequest()

var privacyPolicyURL = "https://t2y-customernew.web.app/privacy-policy"

var countryCodeConstant = "+61"
var countryConstant = "Australia"

extension UIColor {
    static let primary = #colorLiteral(red: 0, green: 0.2, blue: 0.7450980392, alpha: 1)
    static let secondary = #colorLiteral(red: 0.168627451, green: 0.5843137255, blue: 1, alpha: 1)
    static let tertiary = #colorLiteral(red: 0.168627451, green: 0.3843137255, blue: 0.9725490196, alpha: 1)
}

 //  let baseURL = URL(string: "https://trailer2you.herokuapp.com")
  //   let baseURL = URL(string: "https://t2ytest-private.herokuapp.com")
     let baseURL = URL(string: "https://t2ybeta.herokuapp.com/")

//MARK: USER

let loginURL = URL(string: "/signin", relativeTo: baseURL)
let signupURL = URL(string: "/signup", relativeTo: baseURL)
let forgotPasswordURL = URL(string: "/forgotpassword", relativeTo: baseURL)
let resetPasswordURL = URL(string: "/resetpassword", relativeTo: baseURL)
let sendOTPURL = URL(string: "/signup/otp/resend", relativeTo: baseURL)
let verifyOTPURL = URL(string: "/signup/verify", relativeTo: baseURL)
let changePasswordURL = URL(string: "/user/password/change", relativeTo: baseURL)
let userURL = URL(string: "/user?id=", relativeTo: baseURL)
let verifyEmailURL = URL(string: "/customer/email/verify", relativeTo: baseURL)
let updateProfileURL = URL(string: "/user", relativeTo: baseURL)

//MARK: TRAILER RENTAL
let featuredTrailersURL = URL(string: "/featured", relativeTo: baseURL)
let filterItemsURL = URL(string: "/rentalitemfilters", relativeTo: baseURL)
let searchURL = URL(string: "/search", relativeTo: baseURL)
let trailerDetailURL = URL(string: "/trailer/view", relativeTo: baseURL)
let licenseeDetailsURL = URL(string: "/trailer/licensee?id=", relativeTo: baseURL)
let chargesURL = URL(string: "/booking/charges", relativeTo: baseURL)
let bookingURL = URL(string: "/booking", relativeTo: baseURL)

//MARK: TRAILER RENTAL OLD
let notificationsURL = URL(string: "/user/reminders", relativeTo: baseURL)
let rentalURL = URL(string: "/rental?id=", relativeTo: baseURL)
let trailerViewURL = URL(string: "/trailer?id=", relativeTo: baseURL)
let editRentalURL = URL(string: "/rental/edit", relativeTo: baseURL)
let ratingURL = URL(string: "/rating", relativeTo: baseURL)
let reviewURL = URL(string: "/review", relativeTo: baseURL)
let pendingRatingURL = URL(string: "/getPendingRatingRentals", relativeTo: baseURL)
let newRatingURL = URL(string: "/setRatings", relativeTo: baseURL)
let locationTrackingStartURL = URL(string: "/user/rental/location/track", relativeTo: baseURL)



class Keys {
    public static let mobile = "T2YNumber"
    public static let country = "T2YCountry"
}




func DebugRequest(_ url : String, request : Data, response : Data){
    let req = try? JSONSerialization.jsonObject(with: request)
    let res = try? JSONSerialization.jsonObject(with: response)
    
    print("====================================================")
    print("URL: ",url)
    print("\n")
    print("==============      REQUEST BODY      ==============")
    print("\n")
    print(req)
    print("\n")
    print("==============      RESPONSE BODY     ==============")
    print("\n")
    print(res)
    print("\n")
    print("====================================================")
}
