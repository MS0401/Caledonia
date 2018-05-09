//
//  ViewController.swift
//  Caledonia
//
//  Created by For on 6/14/17.
//  Copyright © 2017 For. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import RSLoadingView
import CoreLocation
import Firebase
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginImage: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var avoidingView: UIView!
    
    
    
    //PageControl property
    var timer: Timer!
    var updateCounter: Int!
    
    var swipeGesture = UISwipeGestureRecognizer()
    
    //Loading View property
    let loadingView = RSLoadingView()
    
    ////User Token when login
    var token: String!
    
    //Location Manager - CoreLocation Framework.
    var locationManager = CLLocationManager()
    
    // Declare for progress bar
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    
    var keyboardActive = false
    
    
    //Current location information
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    //NSTimer object for scheduling accuracy changes
    var backgroundTimer: Timer!
    var appDelegate: AppDelegate!
    
    // BackgroundTaskIdentifier for backgrond update location
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    var backgroundTaskIdentifier2: UIBackgroundTaskIdentifier!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //KeyboardAvoiding section
        KeyboardAvoiding.avoidingView = self.avoidingView
        
        //View initialize
        self.loginImage.layer.cornerRadius = 24
        self.email.layer.borderWidth = 1
        self.email.layer.borderColor = UIColor.gray.cgColor
        self.email.layer.shadowColor = UIColor.black.cgColor
        self.email.layer.shadowOpacity = 0.16
        self.email.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.email.layer.cornerRadius = 24
        
        self.password.layer.borderWidth = 1
        self.password.layer.borderColor = UIColor.gray.cgColor
        self.password.layer.shadowColor = UIColor.black.cgColor
        self.password.layer.shadowOpacity = 0.16
        self.password.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.password.layer.cornerRadius = 24
        
        //PageControl section
        updateCounter = 0
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left]
        for direction in directions {
            swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.UpdateTimer))
            self.topImage.addGestureRecognizer(swipeGesture)
            swipeGesture.direction = direction
            self.topImage.isUserInteractionEnabled = true
            self.topImage.isMultipleTouchEnabled = true
        }
        
        //GoogleMap curent location
        
        self.token = ""
        //keeping inputed user's email
        self.retrieveAccountInfo()
        
        // Authorization for utilization of location services for background process
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            // Location Manager configuration
            locationManager.delegate = self
            
            // Location Accuracy, properties
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.allowsBackgroundLocationUpdates = true
            
            locationManager.startUpdatingLocation()
            
        }
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    }
    
    //Keep inputed email
    func retrieveAccountInfo() {
        
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "email") != nil {
            
            self.email.text = defaults.string(forKey: "email")
            self.password.text = defaults.string(forKey: "password")
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func UpdateTimer() {
        if updateCounter <= 2 {
            pageControl.currentPage = updateCounter
            if updateCounter == 0 {
                self.titleLabel.text = "Create a profile"
            }else if updateCounter == 1 {
                self.titleLabel.text = "Save places"
            }else {
                self.titleLabel.text = "Explore"
            }
            updateCounter = updateCounter + 1
        }else {
            updateCounter = 0
        }
    }
    
    @IBAction func LoginAction(_ sender: UIButton) {
        
        let email = self.email.text!
        let password = self.password.text!
        
        let defaults = UserDefaults.standard
        
        defaults.set(email, forKey: "email")
        defaults.set(password, forKey: "password")
                
        if self.email.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            self.loadingView.show(on: view)
            
            Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    //Go to the HomeViewController if the login is sucessful
                    SharedManager.sharedInstance.emailText = self.email.text!
                    self.performSegue(withIdentifier: "loginEmail", sender: self)
                    self.loadingView.hide()
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    self.loadingView.hide()
                }
            }
        }
        
    }
    
    
    @IBAction func Facebook_Login(_ sender: Any) {
        
        loadingView.show(on: view)
        
        let login: FBSDKLoginManager = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self,handler: {(result, error) -> Void in
            if error != nil {
                print("Process error")
            }
            else if (result?.isCancelled)! {
                print("Cancelled")
            }
            else {
                print("Logged in")
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
                
            }
            
        })
    }
    
    func updateLocation() {
        
        let timeRemaining = UIApplication.shared.backgroundTimeRemaining
        
        print("BackgroundTimeRemaining => \(timeRemaining)")
        //        self.token = SharingManager.sharedInstance.token
        
        if timeRemaining > 60.0 {
            
            if self.latitude != nil && self.longitude != nil {
                
                // Send current location and time to server
                self.geoLogLocation(self.latitude, lng: self.longitude)
                
            }
        } else {
            
            if timeRemaining == 0 {
                
                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            }
            backgroundTaskIdentifier2 = UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
                
                // Stops Timer
                self.backgroundTimer.invalidate()
                
                /* Timer initialized everytime an update is received. When timer expires, reverts accuracy to HiGH, thus enabling the delegate to receive new location updates */
                self.backgroundTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(ViewController.updateLocation), userInfo: nil, repeats: true)
            })
        }
    }
    
    // Send current location and time with Json data to server
    func geoLogLocation(_ lat: CLLocationDegrees, lng: CLLocationDegrees) {
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendList" {
            _ = segue.destination as! LMRootViewController
            //login.first = false
            RSLoadingView.hide(from: view)
        }else if segue.identifier == "loginEmail" {
            _ = segue.destination as! LMRootViewController
//            //login.first = false
//            let emailtxt = self.email.text!
//            let temp = emailtxt.components(separatedBy: "@")
//            let reallytxt = temp.first
            
             SharedManager.sharedInstance.emailText =  self.email.text!
        }
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print("+++++++++++++++++++++++++++++")
                    print("result is \(result!)")
                    SharedManager.sharedInstance.tempData = result as? [String : AnyObject]
                    print("Share result is \(String(describing: SharedManager.sharedInstance.tempData!))")
                    SharedManager.sharedInstance.isLogin = true
                    
                    self.performSegue(withIdentifier: "friendList", sender: self)
                    self.loadingView.hide()
                }
            })
        }
    }
    
    
    //textFieldDelegate method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        KeyboardAvoiding.avoidingView = self.avoidingView
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
}

// MARK: - CLLocationManagerDelegate
extension ViewController:  CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = locValue.latitude
        self.longitude = locValue.longitude
        SharedManager.sharedInstance.currentLoc = locValue
        SharedManager.sharedInstance.currentLocation = "\(locValue.latitude), \(locValue.longitude)"
        
        if UIApplication.shared.applicationState == .active {
            
        } else {
            
            backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
                
                // Stops Timer
                self.backgroundTimer.invalidate()
                
                /* Timer initialized everytime an update is received. When timer expires, reverts accuracy to HiGH, thus enabling the delegate to receive new location updates */
                self.backgroundTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(ViewController.updateLocation), userInfo: nil, repeats: true)
                
            })
        }
    }
}

