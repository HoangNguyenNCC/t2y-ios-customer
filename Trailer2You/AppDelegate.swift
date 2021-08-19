//
//  AppDelegate.swift
//  Trailer2You
//
//  Created by Aritro Paul on 02/02/20.
//  Copyright © 2020 Aritro Paul. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Stripe
import Firebase
import Atlantis
import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        //  GMSServices.provideAPIKey("AIzaSyA-Vp1JF3YISWdVswOVC0Hqk_s7hIdIPug")
        // Stripe.setDefaultPublishableKey("pk_test_CyIf8HRNFvrXTivqfBr8SIua00dBYroXEr")
        
        Stripe.setDefaultPublishableKey("pk_test_51HCsxqGLBR8nomTlmnpEx2ZJnVduO1hAR6hZtDdNQxlkyeaRBaobtSE8ypCRXLAScUswLzCm2l0TF2qlOgn2CDm800dgEJDHRM")
        
        FirebaseApp.configure()
        
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        Messaging.messaging().delegate = self
        
        UserDefaults.standard.set(Messaging.messaging().fcmToken, forKey: "fcm")
        
        application.registerForRemoteNotifications()
        
//        InstanceID.instanceID().instanceID { (result, error) in
//          if let error = error {
//            print("Error fetching remote instance ID: \(error)")
//          } else if let result = result {
//            print("Remote instance ID token: \(result.token)")
//            self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
//          }
//        }
        Atlantis.start()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(fcmToken)")
        if let fcm = fcmToken {
      let dataDict:[String: String] = ["token": fcm]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        }
    }
    
//    func application(application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//      Messaging.messaging().apnsToken = deviceToken
//    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo["gcmMessageIDKey"] {
        print("Message ID: \(messageID)")
      }
        
        print("NOTIFICATION RECEIVED 2 !!!")


      // Print full message.
      print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo["gcmMessageIDKey"] {
        print("Message ID: \(messageID)")
      }
        
        print("NOTIFICATION RECEIVED!!!")

      // Print full message.
      print(userInfo)
        
        if let invoiceId = userInfo[AnyHashable("rentalId")] as? String {
            if let retrievedToken = KeychainWrapper.standard.string(forKey: "token"), let retrievedUser = KeychainWrapper.standard.string(forKey: "userID") {
                user = retrievedUser
                token = retrievedToken
                print(token)
               // let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                //let vc = storyboard.instantiateViewController(identifier: "rating")
                UserDefaults.standard.set(invoiceId, forKey: "rate")
            }
        }

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
}

