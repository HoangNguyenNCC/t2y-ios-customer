//
//  Services.swift
//  Trailer2You
//
//  Created by Aritro Paul on 13/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import Foundation
import UIKit
import Just

class ServiceController {
    
    static let shared = ServiceController()
    
    func login(withEmail email: String, withPassword password: String, completion: @escaping(Bool, LoginResponse, Error)->()){
        guard let url = loginURL else { return }
        var loginResponse = LoginResponse()
        let fcmToken = UserDefaults.standard.string(forKey: "fcm")
        print("LOGIN TOKEN:",fcmToken)
        Just.post(url, json: ["email": email, "password": password,"fcmDeviceToken":fcmToken],timeout: 60) { r in
            guard let data = r.content else { return }
            if r.ok {
                debug(r)
                loginResponse = try! JSONDecoder().decode(LoginResponse.self, from: data)
                completion(true , loginResponse, Error())
            }
            else {
                print(r.response,r.error)
                var trailerError = Error()
                do {
                    loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    trailerError.errors = loginResponse.errorsList
                    completion(loginResponse.success ?? false, LoginResponse(), trailerError)
                } catch {
                    completion(false , LoginResponse(), Error(errors: ["Please try again!"]))
                }
            }
        }
    }
    
    func signUp(photo: Data?, email: String?, password: String, name: String?, mobile:String?, address: AddressRequest?, dob: String, driversLicense: DriverLicense?,licenseData : Data? ,completion: @escaping(Bool, String?)->()) {
        
        var parameters = [String:String]()
        
        parameters["reqBody[email]"] = email ?? ""
        parameters["reqBody[name]"] = name ?? ""
        parameters["reqBody[mobile]"] = mobile ?? ""
        parameters["reqBody[dob]"] = dob
        parameters["reqBody[password]"] = password
        parameters["reqBody[address][country]"] = address?.country ?? ""
        parameters["reqBody[address][text]"] = address?.text ?? ""
        parameters["reqBody[address][pincode]"] = address?.pincode ?? ""
        parameters["reqBody[address][coordinates][0]"] = address?.lat
        parameters["reqBody[address][coordinates][1]"] = address?.lon
        parameters["reqBody[driverLicense][card]"] = driversLicense?.card ?? ""
        parameters["reqBody[driverLicense][expiry]"] = driversLicense?.expiry ?? ""
        parameters["reqBody[driverLicense][state]"] = driversLicense?.state ?? ""
        
        print(parameters)
        
        let photo = HTTPFile.data("photo", photo!, "image/png")
        
        let scan = HTTPFile.data("driverLicenseScan", licenseData!, "application/pdf")
        
        let url = signupURL!
        
        var signupResponse = FeedbackResponse()
        Just.post(url,data: parameters, files: ["photo" : photo,"driverLicenseScan":scan],timeout: 300){ (r) in
            debug(r)
            if r.ok {
                guard let data = r.content else { return }
                signupResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                completion(signupResponse.success ?? false,signupResponse.message ?? "Error")
            } else {
                do{
                    guard let data = r.content else { return }
                    signupResponse = try JSONDecoder().decode(FeedbackResponse.self, from: data)
                    completion(signupResponse.success ?? false,signupResponse.message ?? "Error")
                } catch {
                completion(false,"Network Error")
                }
            }
        }
    }
    
    
    func getfeaturedTrailers(completion: @escaping(Bool, [FeaturedTrailer], Error)->()) {
        let url : URL! = featuredTrailersURL
        
        var trailerError = Error()
        var trailerResponse = FeaturedTrailerResponse()
        var trailers = [FeaturedTrailer]()
        
        Just.get(url, headers: ["Authorization": token],timeout: 60) { r in
            guard let data = r.content else { return }
            if r.ok {
                debug(r)
                trailerResponse = try! JSONDecoder().decode(FeaturedTrailerResponse.self, from: data)
                trailers = trailerResponse.trailers ?? [FeaturedTrailer]()
                trailerError.errors = trailerResponse.errorsList
                completion(true, trailers, Error())
            } else {
                trailerResponse = try! JSONDecoder().decode(FeaturedTrailerResponse.self, from: data)
                trailerError.errors = trailerResponse.errorsList
                completion(false, [FeaturedTrailer](), trailerError)
            }
        }
    }
    
    func getTrailer(withBooking booking: BookingModel, completion: @escaping(Bool, TrailerDetailResponse , Error)->()) {
        
        guard let url = trailerDetailURL else { return }
        
        var trailerDetailsError = Error()
        var trailerDetailResponse = TrailerDetailResponse()
        
        let params : [String : Any] = ["id":booking.id as Any,"dates":booking.dates!,"times":booking.times!,"delivery":"door2door", "location":booking.address!.coordinates!]
        
        print(params)
        
        Just.post(url, json: params, headers: ["Authorization": token],timeout: 60) { r in
            guard let data = r.content else { return }
            
            if r.ok {
                debug(r)
                trailerDetailResponse = try! JSONDecoder().decode(TrailerDetailResponse.self, from: data) 
                if trailerDetailResponse.trailerObj?.id == nil {
                    completion(false,trailerDetailResponse,Error())
                } else {
                    completion(true, trailerDetailResponse, Error())
                }
            } else {
                trailerDetailResponse = try! JSONDecoder().decode(TrailerDetailResponse.self, from: data)
                trailerDetailsError.errors = trailerDetailResponse.errorsList
                completion(false, TrailerDetailResponse(), trailerDetailsError)
            }
        }
    }
    
    
    
    
    func getReminders(_ type : ReminderType,completion: @escaping(Bool, [Reminder], Error)->()) {
        
        guard let url = notificationsURL else { return }
        
        var trailerError = Error()
        var notificationResponse = NotificationResponse()
        var reminders = [Reminder]()
        
        Just.get(url,params:["count":"30","type":type.rawValue],headers: ["Authorization" : token],timeout: 60) { r in
            guard let data = r.content else { return }
            if r.ok {
                debug(r)
                notificationResponse = try! JSONDecoder().decode(NotificationResponse.self, from: data)
                reminders = notificationResponse.remindersList ?? [Reminder]()
                completion(true, reminders, Error())
            }
            else {
                notificationResponse = try! JSONDecoder().decode(NotificationResponse.self, from: data)
                trailerError.errors = notificationResponse.errorsList
                completion(false, [Reminder](), trailerError)
            }
        }
    }
    
    func sendFeedback(trailerId: String, userId: String, rating: Int, review: String, completion: @escaping(Bool, Error)->()) {
        
        var success = (0,0)
        
        sendRating(trailerId: trailerId, userId: userId, rating: rating) { (status, error) in
            if status {
                success.0 = 1
                if success == (1,1) {
                    completion(true, error)
                }
            }
        }
        
        sendReview(trailerId: trailerId, userId: userId, review: review) { (status, error) in
            if status {
                success.1 = 1
                if success == (1,1) {
                    completion(true, error)
                }
            }
        }
        
    }
    
    func sendRating(trailerId: String, userId: String, rating: Int, completion: @escaping(Bool, Error) ->()) {
        guard let url = ratingURL else { return }
        
        let ratingRequest = ["itemType" : "trailer", "itemId" : trailerId, "ratedByUserId" : userId, "ratingValue" : rating] as [String : Any]
        
        var trailerError = Error()
        var feedbackResponse = FeedbackResponse()
        
        Just.post(url, json: ratingRequest,timeout: 60) { r in
            guard let data = r.content else { return }
            if r.ok {
                feedbackResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                completion(true, Error())
            }
            else {
                feedbackResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                trailerError.errors = feedbackResponse.errorsList
                completion(false, trailerError)
            }
        }
    }
    
    func sendReview(trailerId: String, userId: String, review: String, completion: @escaping(Bool, Error) ->()) {
        guard let url = reviewURL else { return }
        
        let reviewRequest = ["trailerId" : trailerId, "reviewedByUserId" : userId, "reviewText" : review] as [String : Any]
        
        
        var trailerError = Error()
        var feedbackResponse = FeedbackResponse()
        
        Just.post(url, json: reviewRequest,timeout: 60) { r in
            guard let data = r.content else { return }
            if r.ok {
                feedbackResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                completion(true, Error())
            }
            else {
                feedbackResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                trailerError.errors = feedbackResponse.errorsList
                completion(false, trailerError)
            }
        }
    }
    
    func forgotPassword(email: String, completion: @escaping(Bool, Error) ->()) {
        guard let url = forgotPasswordURL else { return }
        
        var trailerError = Error()
        var feedbackResponse = FeedbackResponse()
        
        Just.put(url, json: ["email" : email, "platform":"ios"],timeout: 60) { r in
            guard let data = r.content else { return }
            if r.ok {
                debug(r)
                completion(true, Error())
            }
            else {
                feedbackResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                trailerError.errors = feedbackResponse.errorsList
                completion(false, trailerError)
            }
        }
    }
    
    func resetPassword(token: String, password: String, completion: @escaping(Bool, Error) ->()) {
        guard let url = resetPasswordURL else { return }
        
        var trailerError = Error()
        var feedbackResponse = FeedbackResponse()
        
        Just.put(url, json: ["token" : token, "password" : password],timeout: 60) { r in
            guard let data = r.content else { return }
            if r.ok {
                debug(r)
                completion(true, Error())
            }
            else {
                feedbackResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                trailerError.errors = feedbackResponse.errorsList
                completion(false, trailerError)
            }
        }
    }
    
    func getLicenseeDetails(withLicenseeId id: String, completion: @escaping(Bool, LicenseeObject, Error) -> ()) {
        guard let url = URL(string: (licenseeDetailsURL?.absoluteString ?? "")+id) else { return }
        
        var licenseeError = Error()
        var licenseeResponse = Licensee()
        var licensee = LicenseeObject()
        
        Just.get(url, headers: ["Authorization": token],timeout: 60) { r in
            guard let data = r.content else { return }
            if r.ok {
                debug(r)
                licenseeResponse = try! JSONDecoder().decode(Licensee.self, from: data)
                licensee = licenseeResponse.licenseeObj ?? LicenseeObject()
                completion(true, licensee, Error())
            }
            else {
                licenseeResponse = try! JSONDecoder().decode(Licensee.self, from: data)
                licenseeError.errors = licenseeResponse.errorsList
                completion(false, licensee, licenseeError)
            }
        }
    }
    
    func editProfiles(params : [String:String],photo : Data?,licenseData : Data?,completion: @escaping(Bool,User?,String)->()) {
        guard let url = updateProfileURL else { return }
        
        let param = getUpdateParams(params)
        print("PARAMS: \n",param)
        var updateError = Error()
        var updateResponse = ProfileResponse()
        
        var media = [String:HTTPFile]()
        
        if let photo = photo {
            let photoFile = HTTPFile.data("photo", photo, "image/png")
            media["photo"] = photoFile
        }
        
        if let licenseData = licenseData {
            let scan = HTTPFile.data("driverLicenseScan", licenseData, "application/pdf")
            media["driverLicenseScan"] = scan
        }
        
        Just.put(url,data: param, headers: ["Authorization":token], files: media,timeout: 60) { (r) in
            guard let data = r.content else { return }
            debug(r)
            do {
                updateResponse = try JSONDecoder().decode(ProfileResponse.self, from: data)
            } catch {
                updateError.errors?.append("Service Unavailable")
            }
            
            completion(updateResponse.success ?? false,updateResponse.userObj,updateResponse.message ?? "Error")
            
        }
    }
    
    func sendOTP(to number:String, in country: String, completion: @escaping(Bool, Error) -> ()) {
        guard let url = sendOTPURL else { return }
        
        var trailerError = Error()
        var OTPResponse = FeedbackResponse()
        
        print(["mobile" : number, "country" : country])
        
        Just.post(url, json: ["mobile" : number, "country" : country],timeout: 60) { (r) in
            guard let data = r.content else { return }
            if r.ok {
                debug(r)
                OTPResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                completion(true, Error())
            }
            else {
                OTPResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                trailerError.errors = OTPResponse.errorsList
                completion(false, trailerError)
            }
        }
    }
    
    func verifyOTP(to number: String, in country: String, otp: String, completion: @escaping(Bool, Error)->()) {
        guard let url = verifyOTPURL else { return }
        
        var trailerError = Error()
        var OTPResponse = FeedbackResponse()
        
        Just.post(url, json: ["mobile" : number, "country" : country, "otp": otp],timeout: 60) { (r) in
            guard let data = r.content else { return }
            if r.ok {
                debug(r)
                OTPResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                completion(true, Error())
            }
            else {
                OTPResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                trailerError.errors = OTPResponse.errorsList
                completion(false, trailerError)
            }
        }
    }
    
    func verifyEmail(to email : String? ,completion: @escaping(Bool,Error)->()){
        guard let url = verifyEmailURL else { return }
        
        guard let email = email else { completion(false,Error()) ; return }
        
        var trailerError = Error()
        var OTPResponse = FeedbackResponse()
        Just.post(url, json: ["email":email],headers: ["Authorization": token],timeout: 60) { (r) in
            guard let data = r.content else { return }
            if r.ok {
                debug(r)
                OTPResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                completion(true, Error())
            }
            else {
                OTPResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
                trailerError.errors = OTPResponse.errorsList
                completion(false, trailerError)
            }
        }
    }
    
    func getFilterItems(completion: @escaping(Bool, Filters, Error) -> ()) {
        guard let url = filterItemsURL else { return }
        
        var filters = Filters()
        var filterResponse = FilterResponse()
        
        Just.get(url, headers: ["Authorization": token],timeout: 60) { (r) in
            guard let data = r.content else { return }
            filterResponse = try! JSONDecoder().decode(FilterResponse.self, from: data)
            if r.ok {
                debug(r)
                filters = filterResponse.filtersObj ?? Filters()
                completion(true, filters, Error())
            }
            else {
                var error = Error()
                error.errors = filterResponse.errorsList
                completion(false, Filters(), error)
            }
        }
    }
    
    func searchTrailers(location : [Double], dates : [String], times : [String], filters: [String : [String]] = [String : [String]](),skip:Int,count:Int, completion: @escaping(Bool, [TrailerResult], Error) -> ()) {
        guard let url = searchURL else { return }
        
        var trailers = [TrailerResult]()
        var searchResponse = SearchResponse()
        
        var body = ["location" : location, "dates" : dates, "times" : times, "item" : "trailer","skip":skip,"count":count] as [String : Any]
        
        if let type = filters["type"] {
            body["type"] = type
        }
        
        if let delivery = filters["delivery"] {
            body["delivery"] = delivery
        }
        
        print("request:",body)
        Just.post(url,json: body, headers: ["Authorization": token],timeout: 60) { (r) in
            guard let data = r.content else { return }
            print("STATUS: ",r.statusCode)
            if r.ok {
                debug(r)
                searchResponse = try! JSONDecoder().decode(SearchResponse.self, from: data)
                trailers = searchResponse.trailers ?? [TrailerResult]()
                completion(true, trailers, Error())
            } else {
                do {
                searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                trailers = searchResponse.trailers ?? [TrailerResult]()
                completion(false, trailers, Error(errors: [searchResponse.message ?? "Error"]))
                } catch {
                var error = Error()
                error.errors = searchResponse.errorsList
                completion(false, [TrailerResult](), error)
                }
            }
        }
    }
    
    func getUser(withID userID: String, completion: @escaping(Bool, User, Error)->()) {
        guard let url = URL(string: userURL!.absoluteString + userID) else { return }
        
        var userResponse = UserResponse()
        
        Just.get(url, headers: ["Authorization": token],timeout: 60) { (r) in
            guard let data = r.content else { return }
            
            userResponse = try! JSONDecoder().decode(UserResponse.self, from: data)
            if r.ok {
                debug(r)
                let user = userResponse.userObj
                completion(true, user ?? User(), Error())
            } else {
                var error = Error()
                error.errors = userResponse.errorsList
                completion(false, User(), error)
            }
        }
    }
    
    func getRental(withID invoiceID: String, completion: @escaping(Bool, InvoiceObj, Error) -> ()) {
        guard let url = URL(string: (rentalURL?.absoluteString)! + "\(invoiceID)") else { return }
        
        var rentalResponse = RentalResponse()
        
        Just.get(url, headers: ["Authorization": token],timeout: 60) { (r) in
            guard let data = r.content else { return }
            
            debug(r)
            
            rentalResponse = try! JSONDecoder().decode(RentalResponse.self, from: data)
            if r.ok {
                let rental = rentalResponse.rentalObj ?? InvoiceObj()
                completion(true, rental, Error())
            }
            else {
                var error = Error()
                error.errors = rentalResponse.errorsList
                completion(false, InvoiceObj(), error)
            }
        }
    }
    
    
    func setupCustomerPayment(payment: Payment, completion: @escaping(Bool, SetupPaymentResponse)->()) {
        guard let url = bookingURL else { return }
        
        let invoiceData = try? JSONSerialization.jsonObject(with: try! JSONEncoder().encode(payment)) as? [String : Any]
        
        var invoiceResponse = SetupPaymentResponse()
        
        print(invoiceData)
        
        Just.post(url, json: invoiceData, headers: ["Authorization": token],timeout: 60) { (r) in
            guard let data = r.content else { return }
            debug(r)
            invoiceResponse = try! JSONDecoder().decode(SetupPaymentResponse.self, from: data)
            if r.ok {
                completion(true, invoiceResponse)
            } else {
                completion(false, invoiceResponse)
            }
        }
    }
    
    
    func changePassword(oldPassword: String, newPassword: String, completion: @escaping(Bool, String) -> ()) {
        guard let url = changePasswordURL else { return }
        
        var trailerError = Error()
        var changeResponse = FeedbackResponse()
        
        Just.put(url, json: ["oldPassword": oldPassword, "newPassword" : newPassword], headers: ["Authorization": token],timeout: 60) { (r) in
            guard let data = r.content else { return }
            changeResponse = try! JSONDecoder().decode(FeedbackResponse.self, from: data)
            completion(changeResponse.success ?? false,changeResponse.message ?? "Error" )
        }
    }
    
    func getCharges(_ booking: ChargesRequestModel, completion: @escaping(Bool, ChargesResponseModel , Error)->()) {
        
        guard let url = chargesURL else { return }
        
        var charges = ChargesResponseModel()
        
        let bookingData = try? JSONSerialization.jsonObject(with: try! JSONEncoder().encode(booking)) as? [String : Any]
        
        Just.post(url, json: bookingData,headers: ["Authorization": token],timeout: 60) { (r) in
            
            guard let data = r.content else { return }
            
            debug(r)
            
            charges = try! JSONDecoder().decode(ChargesResponseModel.self, from: data)
            
            if r.ok {
                completion(true, charges, Error())
            } else {
                print(r.error)
            }
        }
    }
    
    func editRental(model : EditRentalModel, completion: @escaping(Bool,RescheduleResponse?,String) -> ()) {
        guard let url = editRentalURL else { return }
        
        var rentalResponse = RescheduleResponse()
        
        var body = ["rentalId" : model.rentalID, "bookingId":model.bookingID,"type": model.type.rawValue]
        
        if model.type != .cancel {
            body["newEndDate"] = model.endDate
            body["newStartDate"] = model.startDate
        }
        
        print(body)
        
        Just.post(url, json: body, headers: ["Authorization": token],timeout: 60) { (r) in
            guard let data = r.content else { return }
            
            debug(r)
            
            rentalResponse = try! JSONDecoder().decode(RescheduleResponse.self, from: data)
            if r.ok {
                completion(true,rentalResponse,"")
            }
            else {
                let error  = rentalResponse.message
                completion(false,nil,error ?? "Error")
            }
        }
    }
    
    func getPendingRentals(completion:@escaping([ReviewData])->()){
        guard let url = pendingRatingURL else { return }
        Just.get(url, headers: ["Authorization": token],timeout: 60) { (r) in
            guard let data = r.content else { return }
            debug(r)
            
            let response = try! JSONDecoder().decode([ReviewData].self, from: data)
            if r.ok{
                completion(response)
            } else {
                completion([])
            }
        }
    }
    
    func rateTrailer(invoiceId:String,rating:Int,review:String,licensee:Int = -1,completion: @escaping(Bool)->()){
        guard let url = newRatingURL else { return }
        var body = ["invoiceId":invoiceId,"rating":rating,"review":review] as [String : Any]
        if (licensee > -1) { body["licenseeRating"] = licensee }
        Just.post(url,json: body, headers: ["Authorization": token],timeout: 60) { (r) in
            debug(r)
            completion(true)
        }
        
    }
    
    
    
    func getTrailerDetails(withId trailerId: String?, completion: @escaping(Bool, TrailerDetailsModel , Error)->()) {
        
        guard let url = trailerViewURL else { return }
        
        var trailerDetails = TrailerDetailsModel()
        
        guard let id = trailerId else { return }
        
        Just.get(url, params: ["id" : id],headers: ["Authorization": token],timeout: 60) { (r) in
            
            guard let data = r.content else { return }
            
            debug(r)
            
            trailerDetails = try! JSONDecoder().decode(TrailerDetailsModel.self, from: data)
            
            if r.ok {
                completion(true, trailerDetails, Error())
            }
            else {
                var error = Error()
                error.errors = trailerDetails.errorsList
                completion(false, TrailerDetailsModel(), error)
            }
        }
    }
    
    func getUpdateParams(_ params : [String:String])->[String:String]{
        var updateParam = [String:String]()
        updateParam = params.filter{ $0.value != "" && $0.value != "0.0"}
        return updateParam
    }
}

enum rentalEditType : String {
    case extend, reschedule, cancel
}


func debug(_ r: HTTPResult){
    print("===================================")
    print(r.url)
    print("\n\n")
    print(r.json)
    print("\n\n")
}

extension ServiceController {
    
    func sendLocationStartData(rentalId: String, type: String, action: String, completion: @escaping(Bool,locationStartResponseModel,Error) ->()) {
        
        guard let url = locationTrackingStartURL else { return }
        
        let reviewRequest = ["rentalId" : rentalId, "type" : type, "action" : action] as [String : Any]
        
        
        var locationError = Error()
        
        Just.post(url, json: reviewRequest,headers: ["Authorization": token]) { r in
            guard let data = r.content else { return }
            if r.ok {
                do {
                    let locationResponse = try JSONDecoder().decode(locationStartResponseModel.self, from: data)
                    completion(true,locationResponse,Error())
                }catch {
                    completion(true,locationStartResponseModel(),Error(errors: ["Error"]))
                }
            }
            else {
                do{
                    let locationResponse = try JSONDecoder().decode(locationStartResponseModel.self, from: data)
                    locationError.errors = locationResponse.errorsList
                    completion(false, locationResponse ,locationError)
                }catch {
                    print(error)
                }
                
            }
        }
    }
}
