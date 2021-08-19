# trailer-ios-customer

- Trailer2You customer application helps customers to book their choice of trailer based on their chosen location , dates and times.


# Installation 🛠
- Clone / download this repository.
- change the bundle identifier in project settings.
- run the app.

### ⚠️ Project is built using Xcode 11.4
### ⚠️ Project target is iOS 13.0


# Overview:

- [MVC architecture](https://en.wikipedia.org/wiki/Model–view–controller) is followed in app.
- [camelCase](https://en.wikipedia.org/wiki/Camel_case) naming convention is used.
- [Main.storyboard](https://github.com/applutions/trailer-ios-customer/blob/master/Trailer2You/Base.lproj/Main.storyboard) contains all the viewControllers.

# Pods installed :


Pod | Usage
------------ | -------------
PhoneNumberKit | international phone number validation.
Just | Networking ( GET / POST / PUT requests ).
Kingfisher | Download Images from url + cache them. 
OTPFieldView | setup OTPView UI.
SPAlert | Success / error alerts.
ProgressHUD | Loading indicators.
JTAppleCalendar | CalenderView used to pick dates.
Socket.IO-Client-Swift | Location tracking.
Stripe | Payments.
Firebase Crashlytics | keep track of crashes.


# Important :

Stripe Default Publishable Key present in [appDelegate](https://github.com/applutions/trailer-ios-customer/blob/master/Trailer2You/AppDelegate.swift)
``` swift
Stripe.setDefaultPublishableKey("pk_test_CyIf8HRNFvrXTivqfBr8SIua00dBYroXEr")
``` 
[Constants.swift](https://github.com/applutions/trailer-ios-customer/blob/master/Trailer2You/Utils/Constants.swift) contains all networking endpoints.

[Services directory](https://github.com/applutions/trailer-ios-customer/tree/master/Trailer2You/Services) contains all Networking classes.

[Customer Fonts: ]() New York Extra Large

## Color-Scheme
- ![#0033BE](https://via.placeholder.com/15/0033BE/000000?text=+) `Primary`
- ![#2B95FF](https://via.placeholder.com/15/2B95FF/000000?text=+) `Secondary`
- ![#2B62F8](https://via.placeholder.com/15/2B62F8/000000?text=+) `Tertiary`
# Basic Flow

## Controller
#### The Controller Folder is divided into 4 parts.

<details>
<summary>Pre-Login</summary>
<br>
SplashViewController : Splash 
<br>
LoginViewController : Login 
<br>
SignupViewController : Signup
<br>
DLViewController : Driver's License 
<br>
AddressViewController : Adress
<br>
AddressFinderViewController : Address autoComplete
<br>
OTPViewController :OTP
<br>
SuccessViewController : Success signup
<br>
ForgotPasswordViewController : Forgot Password
<br>
ResetPasswordViewController : Reset Password
</details>

<details>
<summary>Main</summary>
<br>
HomeViewController : Home + Featured Trailers 
<br>
DatesViewController : Dates 
<br>
DurationViewController : Times
<br>
TrailerViewController : Search results
<br>
FilterTableViewController : Filter
<br>
SortingTableViewController : Sort
<br>
PDFViewController : PDF
<br>
NotificationsViewController : Reminders
<br>
SettingsViewController : Settings
<br>
EditProfileViewController : Edit Profile
<br>
ChangePasswordViewController : Change password
<br>
AboutUsViewController : AboutUS
</details>

<details>
<summary>Booking</summary>
<br>
TrailerDetailsViewController : Details of selected trailer
<br>
LicenseeDetailsViewController : Details of trailer's licensee 
<br>
ConfirmationViewController : confirm
<br>
PaymentViewController : Payment
</details>

<details>
<summary>Post Booking</summary>
<br>
BookedTrailerDetailsViewController : Details of selected trailer
<br>
UpcomingBookingTableViewController : booking list
<br>
TrackingViewController : Location Tracking
<br>
RatingsViewController : Rating
</details>


## View
#### The Views Folder consists of 5 things.
- Headers
- Footers
- Customer bottomBar
- TableViewCells
- UIKit extensions

## Model
#### 🌐 ALL MODELS ARE STRUCTS CONFORMING TO CODABLE PROTOCOL  
- Request models
- response models
- payments models
- tracking models

## Delegates
#### ViewController extensions for delegates
- TableView
- CollectionView
- TextField
- VNDocumentCameraViewController
- PayCards
- Mapkit



