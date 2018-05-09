//
//  MapViewController.swift
//  Caledonia
//
//  Created by For on 6/16/17.
//  Copyright © 2017 For. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import CoreLocation
import SDWebImage
import FBSDKLoginKit
import FBSDKCoreKit
import AAViewAnimator
import XLActionController
import RSLoadingView
import Firebase
import FirebaseDatabase


class MapViewController: UIViewController, ImageCarouselViewDelegate, UITextFieldDelegate, GMSAutocompleteFetcherDelegate {
    
    /**
     * Called when an autocomplete request returns an error.
     * @param error the error that was received.
     */
    public func didFailAutocompleteWithError(_ error: Error) {
        //        resultText?.text = error.localizedDescription
    }
    
    /**
     * Called when autocomplete predictions are available.
     * @param predictions an array of GMSAutocompletePrediction objects.
     */
    public func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        //self.resultsArray.count + 1
        
        for prediction in predictions {
            
            if let prediction = prediction as GMSAutocompletePrediction!{
                self.searchResult.append(prediction.attributedFullText.string)
            }
        }
        self.searchResultController.reloadDataWithArray(self.searchResult)
        //   self.searchResultsTable.reloadDataWithArray(self.resultsArray)
        print(searchResult)
    }
    
    //Search section initialize
    var searchResultController : SearchResultsController!
    var gmsFetcher : GMSAutocompleteFetcher!
    var searchResult = [String]()
    var searchView = UITableView()
    var markerLatitude : Double!
    var markerLongitude : Double!

    
    static let sharedMap = MapViewController()
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    var photoID = 0
        
    // The currently selected place.
    var selectedPlace: GMSPlace?
    var placeIDString: String!
    
    //GoogleMapView property
    var placesClient: GMSPlacesClient!
    var selectIndex: Int!
    var placeIDs: [String] = [String]()
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationMaker: GMSMarker!
    var usersMarker = [GMSMarker]()
    
    //RSLoadingView
    let loadingView = RSLoadingView()
    var ref: DatabaseReference!
    
    
    // CLLocationCoordinate2D Array
    var coordinates = CLLocationCoordinate2D()
    var currentPlace = CLLocationCoordinate2D()
    
    // Camra Location Dictionary
    var cameraLocation = [String: Double]()
    
    //layout initialize
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var filterTag: UIView!
    @IBOutlet weak var seeAllTag: UIButton!
    @IBOutlet weak var filterDismiss: UIButton!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var photoView: ImageCarouselView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editTagView: UIView!
    @IBOutlet weak var searchPlace: UIButton!
    @IBOutlet weak var addInstagram: UIButton!
    @IBOutlet weak var addLabel: UILabel!    
    @IBOutlet weak var bar_btn: UIButton!
    @IBOutlet weak var root_btn: UIButton!
    @IBOutlet weak var restaurant_btn: UIButton!
    @IBOutlet weak var creattagLabel: UILabel!
    @IBOutlet weak var inputtagName: UITextField!
    @IBOutlet weak var yello_btn: UIButton!
    @IBOutlet weak var blue_btn: UIButton!
    @IBOutlet weak var red_btn: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var placeName_txt: UITextField!
    @IBOutlet weak var address_txt: UITextField!
    @IBOutlet weak var tagScroll1: TLTagsControl!
    @IBOutlet weak var tagScroll2: TLTagsControl!
    @IBOutlet weak var tagScroll3: TLTagsControl!
    @IBOutlet weak var tagScroll4: TLTagsControl!
    
    var emailtext: String!
    var dropDown = Bool()
    var edit = Bool()
    var photoArray: [UIImage] = [UIImage]()
    var informations: [DropDownInformation] = [DropDownInformation]()
    var pageIndex = 0
    
    var tempTagText: String!
    var tempTagColor: String!
    var tempTagCoordinate: String!
    var tempTagLatitude: CLLocationDegrees!
    var tempTagLogitude: CLLocationDegrees!
    var tagText: String!
    var tagColor: UIColor!
    var tagBool = false
    var tagNames: [String] = [String]()
    var tagname_download: [String] = [String]()
    var placeAndLocation: [NSDictionary] = [NSDictionary]()
    var tag4Pressed: Bool = false
    var successUploading: Bool = false
    var tagInformation_Download: NSDictionary = NSDictionary()
    var coordinateInfoArray: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.show(on: view)
        
        self.emailtext = SharedManager.sharedInstance.emailText
        
        //Firebase reference path
        self.ref = Database.database().reference()
        
        //Search part delegate
        searchView.delegate = self
        searchView.dataSource = self
        searchView.layer.cornerRadius = 10
        searchView.rowHeight = 30
        searchView.backgroundColor = UIColor.clear
        searchView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
        print(self.searchView.frame)
        print(self.address_txt.frame)
        self.placeName_txt.isEnabled = false
        self.address_txt.isEnabled = false
        
        //KeyboardAvoiding section
        KeyboardAvoiding.avoidingView = self.editTagView
        
        self.photoView.delegate = self
        mapView.delegate = self
        
        //Show Profile Image
        self.DisplayProfileImage()
        
        //Display tag
        self.DownloadingFromFirebase()
        
        //Filter Tag effect
        self.filterTag.layer.backgroundColor = UIColor.white.cgColor
        self.filterTag.layer.opacity = 0.9
        self.filterTag.layer.borderColor = UIColor.init(netHex: 0x979797).cgColor
        self.filterTag.layer.borderWidth = 1
        self.filterTag.layer.shadowColor = UIColor.init(netHex: 0x000000).cgColor
        self.filterTag.layer.shadowRadius = 5
        self.filterTag.layer.shadowOpacity = 0.5
        
        //filterTag hidden
        self.filterTag.isHidden = true
        self.dropDownView.isHidden = true
        
        //Edit Tag View Section.
        self.searchPlace.layer.cornerRadius = 15
        self.addInstagram.layer.cornerRadius = 15
        self.saveButton.layer.cornerRadius = 15
        self.editTagView.layer.cornerRadius = 10
        self.editTagView.isHidden = true
        
        
    }
    
    //Google Map initialize
    func GoogleMapInitialize() {
        
        //GoogleMapInitialize
        mapView.clear()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // Start the update of user's Location
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            placesClient = GMSPlacesClient.shared()
            
            // Location Accuracy, properties
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.allowsBackgroundLocationUpdates = true
            
            locationManager.startUpdatingLocation()
            
            let cameraCoordinate = SharedManager.sharedInstance.currentLoc
            self.mapView.camera = GMSCameraPosition(target: cameraCoordinate!, zoom: 10, bearing: 0, viewingAngle: 0)
            self.setupLocationMarker(cameraCoordinate!)
            
            let geocoder = GMSGeocoder()
            
            geocoder.reverseGeocodeCoordinate(cameraCoordinate!) { response , error in
                if let address = response?.firstResult() {
                    let lines = address.lines! as [String]
                    print("address is \(address)")
                    
                    let current_Address = lines.joined(separator: "")
                    print("my address is \(current_Address)")
                }
            }
        }
    }
    
    //Downloading data from Firebase
    func DownloadingFromFirebase() {
        
        //Tag name downloading from Firebase
        self.ref.child("Caledonia").observe(DataEventType.value, with: { snapshot in
            for item in snapshot.children {
                print("item is \(item)")
                let child = item as! DataSnapshot
                let dict = child.value as! NSDictionary
                print("dict is \(dict)")
                let image = dict["ProfileImage"] as! NSDictionary
                let image1 = image["profileImage"] as! NSDictionary
                print("child is \(image1)")
                self.tagname_download = image1["tagName"] as! [String]
                print(self.tagname_download)
                
                
                if let taginformate = dict["TagInformation"] as? NSDictionary {
                    self.tagInformation_Download = taginformate
                    print("tagInformation_download is \(self.tagInformation_Download)")
                    self.DisplayAllTags()
                    self.DisplayAllLocation()
                    self.displayOtherLocation()
                }
                
            }
        })

        print("tagname_download is \(tagname_download)")
    }
    
    //Display all tags
    func DisplayAllTags() {
        for item in self.tagname_download {
            
            print("item is \(item)")
            //display all tags of tagScroll3
            self.tagScroll1.tags.add(item)
            self.tagScroll1.mode = TLTagsControlMode.edit
            self.tagScroll1.tagPlaceholder = ""
            self.tagScroll1.tagsTextColor = UIColor.white
            self.tagScroll1.tagsDeleteButtonColor = UIColor.white
            
            
            //display all tags of tagScroll2
            self.tagScroll2.tags.add(item)
            self.tagScroll2.mode = TLTagsControlMode.edit
            self.tagScroll2.tagPlaceholder = ""
            self.tagScroll2.tagsTextColor = UIColor.white
            self.tagScroll2.tagsDeleteButtonColor = UIColor.white
            
            
            //display all tags of tagScroll4
            self.tagScroll4.tags.add(item)
            self.tagScroll4.mode = TLTagsControlMode.edit
            self.tagScroll4.tagPlaceholder = ""
            self.tagScroll4.tagsTextColor = UIColor.white
            self.tagScroll4.tagsDeleteButtonColor = UIColor.white
                        
            //Get tag color
            let eachTag = self.tagInformation_Download["\(item)"] as! NSDictionary
            let tagColorS = eachTag["tagColor"] as! String
            let yellowColor = UIColor.init(netHex: 0xE3D63C)
            let blueColor = UIColor.init(netHex: 0x3246A7)
            let redColor = UIColor.init(netHex: 0xEF5350)
            if tagColorS == "yellow" {
                self.tagScroll1.tagsbackgroundColor.add(yellowColor)
                self.tagScroll2.tagsbackgroundColor.add(yellowColor)
                self.tagScroll4.tagsbackgroundColor.add(yellowColor)
            }else if tagColorS == "blue" {
                self.tagScroll1.tagsbackgroundColor.add(blueColor)
                self.tagScroll2.tagsbackgroundColor.add(blueColor)
                self.tagScroll4.tagsbackgroundColor.add(blueColor)
            }else if tagColorS == "red" {
                self.tagScroll1.tagsbackgroundColor.add(redColor)
                self.tagScroll2.tagsbackgroundColor.add(redColor)
                self.tagScroll4.tagsbackgroundColor.add(redColor)
            }
            self.tagScroll1.reloadTagSubviews()
            self.tagScroll1.tapDelegate = self
            self.tagScroll2.reloadTagSubviews()
            self.tagScroll2.tapDelegate = self
            self.tagScroll4.reloadTagSubviews()
            self.tagScroll4.tapDelegate = self
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        var imageURL: String!
        
        //download image URL from Firebase
        self.ref.child("Caledonia").observe(DataEventType.value, with: { snapshot in
            for item in snapshot.children {
                print("item is \(item)")
                let child = item as! DataSnapshot
                let dict = child.value as! NSDictionary
                self.tagInformation_Download = dict["TagInformation"] as! NSDictionary
                let image = dict["ProfileImage"] as! NSDictionary
                let image1 = image["profileImage"] as! NSDictionary
                print("child is \(image1)")
                imageURL = image1["userImage"] as! String
                
                print("imageURL is \(imageURL)")
                
                //display profileImage in imageView
                if imageURL != "" {
                    
                    //Convert from String into Image.
                    let decodeData = NSData(base64Encoded: imageURL, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
                    let image = UIImage(data: decodeData! as Data, scale: 1.0)
                    
                    
                    self.profileImage.image = image
                    self.CircleImage(profileImage: self.profileImage!)
                }else {
                    self.profileImage.image = UIImage(named: "profileImage")
                    self.CircleImage(profileImage: self.profileImage!)
                }
                
                self.GoogleMapInitialize()
                self.loadingView.hide()
            }
        })
    }
    
    //Display all tags of locations
    func DisplayAllLocation() {
        
        self.coordinateInfoArray.removeAll()
        for item in self.tagname_download {
            let eachTag = self.tagInformation_Download["\(item)"] as! NSDictionary
            let eachTagCoordinate = eachTag["Coordinates"] as! [NSDictionary]
            
            for item1 in eachTagCoordinate {
                self.coordinateInfoArray.append((item1["Coordinate"] as! String))
            }
            
        }
        
    }
    
    func displayOtherLocation() {
        usersMarker.removeAll()
        for item in coordinateInfoArray {
            let coordinateString = item.components(separatedBy: ", ")
            
            let coordinate = CLLocationCoordinate2D(latitude: Double(coordinateString.first!)!, longitude: Double(coordinateString.last!)!)
            let userMarker = GMSMarker(position: coordinate)
            userMarker.map = mapView
            userMarker.appearAnimation = GMSMarkerAnimation.pop
            usersMarker.append(userMarker)
        }
        
    }
        
    //Notification
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0{
                let height = keyboardSize.height
                
                self.view.frame.origin.y += height
            }
            
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                let height = keyboardSize.height
                self.view.frame.origin.y -= height
            }
            
        }
    }
    
    //UITextFieldDelegate method
    //textFieldDelegate method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        KeyboardAvoiding.avoidingView = self.editTagView
        if textField == self.inputtagName {
            self.creattagLabel.isHidden = true
        }        
        
        return true
    }
    
    //when text field begin to change in textfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.address_txt.isEditing {
            searchView.frame = CGRect(x:114, y:165, width: Int(self.address_txt.frame.width + 10), height: searchResult.count*30)
            self.editTagView.addSubview(searchView)
            if address_txt.text == nil || address_txt.text == "" {
                searchView.reloadData()
                searchView.removeFromSuperview()
            }else {
                let placesClient = GMSPlacesClient()
                placesClient.autocompleteQuery(string, bounds: nil, filter: nil) {(results, error) -> Void in
                    self.searchResult.removeAll()
                    self.placeIDs.removeAll()
                    if results == nil {
                        return
                    }
                    for result in results! {
                        if let result = result as? GMSAutocompletePrediction {
                        
                            self.placeIDs.append(result.placeID!)
                            self.searchResult.append(result.attributedFullText.string)
                            self.searchView.frame = CGRect(x:114, y:165, width: Int(self.address_txt.frame.width + 10), height: self.searchResult.count*30)
                        }
                    }
                    self.searchView.reloadData()
                }
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchView.removeFromSuperview()
        self.placeName_txt.isEnabled = false
        self.address_txt.isEnabled = false
    }
    
    
    //display profileImage with Facebook
    func DisplayProfileImage() {
        if SharedManager.sharedInstance.isLogin {
            let myData = SharedManager.sharedInstance.tempData!
            print("my data is \(myData)")
            let data = myData
            let profile1 = data["picture"]!
            let profile2 = profile1["data"] as! NSDictionary
            let profile3 = profile2["url"] as! String
            let imgUrl = URL(string: profile3)!
            self.profileImage.sd_setImage(with: imgUrl.absoluteURL)
            self.CircleImage(profileImage: self.profileImage)
        }else {
            
            self.profileImage.image = UIImage(named: "profileImage")
            self.CircleImage(profileImage: self.profileImage)
        }
    }
    
    //making circle image
    func CircleImage(profileImage: UIImageView) {
        // Circle images
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderWidth = 0.5
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true
        
    }
    
    @IBAction func ShowSdieBar(_ sender: UIButton) {
        
        self.sideBarController.showMenuViewController(in: LMSideBarControllerDirection.left)
    }
    
    
    @IBAction func SetYellow(_ sender: UIButton) {
        if self.inputtagName.text != "" {
            
            var duplicate = false
            
            for tag in self.tagScroll4.tags {
                if (tag as! String) == self.inputtagName.text! {
                    duplicate = true
                }
            }
            if !duplicate {
                //tagScroll3 in edittagView
                self.tagScroll3.tags.add(self.inputtagName.text!)
                self.tagScroll3.mode = TLTagsControlMode.edit
                self.tagScroll3.tagPlaceholder = ""
                self.tagScroll3.tagsTextColor = UIColor.white
                self.tagScroll3.tagsDeleteButtonColor = UIColor.white
                self.tagScroll3.tagsbackgroundColor.add(UIColor.init(netHex: 0xE3D63C))
                self.tagScroll3.reloadTagSubviews()
                self.tagScroll3.tapDelegate = self
                
                self.tagText = self.inputtagName.text
                self.tagColor = UIColor.init(netHex: 0xE3D63C)
                self.tagBool = true
                
                self.addLabel.isHidden = true
                self.creattagLabel.isHidden = false
                self.inputtagName.text = ""
                
            }else {
                let alertController = UIAlertController(title: "Sorry!", message: "Your tag name was duplicated. Please input tag name again.", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("you have pressed OK button");
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion:nil)
            }
            
        }else {
            let alertController = UIAlertController(title: "Sorry!", message: "You didn't input tag name. Please input tag name.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                print("you have pressed the Cancel button");
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("you have pressed OK button");
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
        }
        

    }
    @IBAction func SetBlue(_ sender: UIButton) {
        if self.inputtagName.text != "" {
            
            var duplicate = false
            
            for tag in self.tagScroll4.tags {
                if (tag as! String) == self.inputtagName.text! {
                    duplicate = true
                }
            }
            if !duplicate {
                //tagScroll3 in edittagView
                self.tagScroll3.tags.add(self.inputtagName.text!)
                self.tagScroll3.mode = TLTagsControlMode.edit
                self.tagScroll3.tagPlaceholder = ""
                self.tagScroll3.tagsTextColor = UIColor.white
                self.tagScroll3.tagsDeleteButtonColor = UIColor.white
                self.tagScroll3.tagsbackgroundColor.add(UIColor.init(netHex: 0x3246A7))
                self.tagScroll3.reloadTagSubviews()
                self.tagScroll3.tapDelegate = self
                
                self.tagText = self.inputtagName.text
                self.tagColor = UIColor.init(netHex: 0x3246A7)
                self.tagBool = true
                
                self.addLabel.isHidden = true
                self.creattagLabel.isHidden = false
                self.inputtagName.text = ""
                
            }else {
                let alertController = UIAlertController(title: "Sorry!", message: "Your tag name was duplicated. Please input tag name again.", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("you have pressed OK button");
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion:nil)
            }
        }else {
            let alertController = UIAlertController(title: "Sorry!", message: "You didn't input tag name. Please input tag name.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                print("you have pressed the Cancel button");
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("you have pressed OK button");
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
        }
        
    }
    @IBAction func SetRed(_ sender: UIButton) {
        if self.inputtagName.text != "" {
            
            var duplicate = false
            
            for tag in self.tagScroll4.tags {
                if (tag as! String) == self.inputtagName.text! {
                    duplicate = true
                }
            }
            if !duplicate {
                //tagScroll3 in edittagView
                self.tagScroll3.tags.add(self.inputtagName.text!)
                self.tagScroll3.mode = TLTagsControlMode.edit
                self.tagScroll3.tagPlaceholder = ""
                self.tagScroll3.tagsTextColor = UIColor.white
                self.tagScroll3.tagsDeleteButtonColor = UIColor.white
                self.tagScroll3.tagsbackgroundColor.add(UIColor.init(netHex: 0xEF5350))
                self.tagScroll3.reloadTagSubviews()
                self.tagScroll3.tapDelegate = self
                
                self.tagText = self.inputtagName.text
                self.tagColor = UIColor.init(netHex: 0xEF5350)
                self.tagBool = true
                
                self.addLabel.isHidden = true
                self.creattagLabel.isHidden = false
                self.inputtagName.text = ""

            }else {
                let alertController = UIAlertController(title: "Sorry!", message: "Your tag name was duplicated. Please input tag name again.", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("you have pressed OK button");
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion:nil)
            }
            
        }else {
            let alertController = UIAlertController(title: "Sorry!", message: "You didn't input tag name. Please input tag name.", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("you have pressed OK button");
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
        }
        
    }
    
    //See all Tag List
    @IBAction func SeeAllList(_ sender: UIButton) {
        
        self.filterTag.isHidden = false
        self.dropDownView.isHidden = true
    }
    
    @IBAction func FilterDismiss(_ sender: UIButton) {
        self.filterTag.isHidden = true
    }
    
    //Save function
    @IBAction func SavePlace(_ sender: UIButton) {
        
        if self.address_txt.text != "" && self.placeName_txt.text != "" && self.tagBool {
            
            loadingView.show(on: view)
            self.tagBool = false
            self.view.endEditing(true)
            
            let urlpath = "https://maps.googleapis.com/maps/api/geocode/json?address=\(self.searchResult[selectIndex])&sensor=false".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            let url = URL(string: urlpath!)
            // print(url!)
            let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
                // 3
                
                do {
                    if data != nil{
                        let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                        
                        self.markerLatitude = (((((dic.value(forKey: "results") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lat")) as! Double
                        
                        self.markerLongitude = (((((dic.value(forKey: "results") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lng")) as! Double
                        
                        // 4
                        
                    }
                    DispatchQueue.main.async{
                        self.animateWithTransition_EditTag(.toBottom)
                        self.searchResult.removeAll()
                        self.address_txt.endEditing(true)
                        self.ShowMapView()
                        self.UploadingData()
                        self.loadingView.hide()
                    }
                    
                    
                }catch {
                    print("Error")
                }
                
            }
            
            task.resume()
            
        }else {
            
            let alertController = UIAlertController(title: "Sorry!", message: "You are failed. Please input place, address, tag name.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                print("you have pressed the Cancel button");
                self.loadingView.hide()
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("you have pressed OK button");
                self.loadingView.hide()
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    //Firebase uploading function
    func UploadingData() {
        
        if !self.tag4Pressed {
            self.tagScroll4.tags.add(self.tagText)
            self.tagScroll4.mode = TLTagsControlMode.edit
            self.tagScroll4.tagPlaceholder = ""
            self.tagScroll4.tagsTextColor = UIColor.white
            self.tagScroll4.tagsDeleteButtonColor = UIColor.white
            self.tagScroll4.tagsbackgroundColor.add(self.tagColor)
            self.tagScroll4.reloadTagSubviews()
            self.tagScroll4.tapDelegate = self
            
            //Insert tag in tagScroll1 and tagScroll2 view
            self.tagScroll1.tags.add(self.tagText)
            self.tagScroll1.mode = TLTagsControlMode.edit
            self.tagScroll1.tagPlaceholder = ""
            self.tagScroll1.tagsTextColor = UIColor.white
            self.tagScroll1.tagsDeleteButtonColor = UIColor.white
            self.tagScroll1.tagsbackgroundColor.add(self.tagColor)
            self.tagScroll1.reloadTagSubviews()
            self.tagScroll1.tapDelegate = self
            
            self.tagScroll2.tags.add(self.tagText)
            self.tagScroll2.mode = TLTagsControlMode.edit
            self.tagScroll2.tagPlaceholder = ""
            self.tagScroll2.tagsTextColor = UIColor.white
            self.tagScroll2.tagsDeleteButtonColor = UIColor.white
            self.tagScroll2.tagsbackgroundColor.add(self.tagColor)
            self.tagScroll2.reloadTagSubviews()
            self.tagScroll2.tapDelegate = self
        }
        
        let tempname = self.emailtext.components(separatedBy: "@")
        let userName = tempname.first!
        let tagname = self.tagText
        var bgColorText: String? = nil
        bgColorText = ""
        let yellowColor = UIColor.init(netHex: 0xE3D63C)
        let blueColor = UIColor.init(netHex: 0x3246A7)
        let redColor = UIColor.init(netHex: 0xEF5350)
        if self.tagColor == yellowColor {
            bgColorText = "yellow"
        }else if self.tagColor == blueColor {
            bgColorText = "blue"
        }else if self.tagColor == redColor {
            bgColorText = "red"
        }
        
        //avoiding tag name duplicate.
        print("tag name downlaod is \(tagname_download)")
        if tag4Pressed {
            for item in tagname_download {
                tagNames.append(item)
            }
        }else {
            for item in tagname_download {
                tagNames.append(item)
            }
            tagNames.append(self.tagText)
        }
        print("tagname is \(tagNames)")
        
        /**
        //comapre either coordinate duplicate or not.
        **/
        
        //tag property
        let individualTag: NSDictionary = ["tagName": tagNames, "userImage": ""]
        
        //coordinates values
        let location = "\(self.markerLatitude!), \(self.markerLongitude!)"
        let placeName = self.placeName_txt.text!
        let locations: NSDictionary = ["Coordinate": location, "placeName": placeName] as NSDictionary
        
        print("self.tagText is \(self.tagText!)")
        
        //compare either tag name is equal or is not.
        if tag4Pressed {
            let tagName = self.tagInformation_Download["\(self.tagText!)"] as! NSDictionary
            let coordinate = tagName["Coordinates"] as! [NSDictionary]
            for item in coordinate {
                self.placeAndLocation.append(item)
            }
            self.placeAndLocation.append(locations)
        }else {
            placeAndLocation.append(locations)
        }
        
        let individualTag1: NSDictionary = ["tagName": tagname!, "tagColor": bgColorText!, "Coordinates": placeAndLocation]
        
        //add firebase child node
        let child1 = ["/Caledonia/\(userName)/ProfileImage/profileImage/": individualTag] // profile Image uploading
        let child = ["/Caledonia/\(userName)/TagInformation/\(self.tagText!)/": individualTag1] // tag property uploading
        
        //Write data to Firebase
        self.ref.updateChildValues(child1)
        self.ref.updateChildValues(child)
        
        //Tag name downloading from Firebase
        self.ref.child("Caledonia").observe(DataEventType.value, with: { snapshot in
            for item in snapshot.children {
                print("item is \(item)")
                let child = item as! DataSnapshot
                let dict = child.value as! NSDictionary
                self.tagInformation_Download = dict["TagInformation"] as! NSDictionary
                let image = dict["ProfileImage"] as! NSDictionary
                let image1 = image["profileImage"] as! NSDictionary
                print("child is \(image1)")
                self.tagname_download = image1["tagName"] as! [String]
                print(self.tagname_download)
                
            }
        })
        print("tagname_download is \(tagname_download)")
        
        self.successUploading = true
               
        self.placeName_txt.text = ""
        self.address_txt.text = ""
        self.tagText = nil
        self.tagNames.removeAll()
        self.placeAndLocation.removeAll()
        self.tag4Pressed = false
        
        

    }
    
    //Location Marker
    func setupLocationMarker(_ coordinate: CLLocationCoordinate2D) {
        if locationMaker != nil {
            locationMaker.map = nil
        }
        locationMaker = GMSMarker(position: coordinate)
        locationMaker.map = mapView
        
        locationMaker.appearAnimation = GMSMarkerAnimation.pop
        locationMaker.icon = nil
        let image = self.profileImage.image
        locationMaker.iconView = image?.circle
        
    }

    @IBAction func CurrentLocation(_ sender: UIButton) {
        // Start the update of user's Location
        if CLLocationManager.locationServicesEnabled() {
            
            // Location Accuracy, properties
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.allowsBackgroundLocationUpdates = true
            
            locationManager.startUpdatingLocation()
            
            let cameraCoordinate = SharedManager.sharedInstance.currentLoc
            self.mapView.camera = GMSCameraPosition(target: cameraCoordinate!, zoom: 12, bearing: 0, viewingAngle: 0)            
        }
    }
    
    //Go Function
    @IBAction func Go_Function(_ sender: UIButton) {
        self.animateWithTransition(.toTop)
        self.CreateActionSheet()
    }
    
    func CreateActionSheet() {
                
        //current Page Coordinate
        let index = SharedManager.sharedInstance.currentPageIndex
        print("index is \(SharedManager.sharedInstance.currentPageIndex)")
        let coordinate = self.informations[index].selectedCoordinate
        print("coordinate is \(coordinate)")
        
        let actionController = YoutubeActionController()
        actionController.addAction(Action(ActionData(title: "Car", image: UIImage(named: "star")!), style: .default, handler: { action in
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                UIApplication.shared.openURL(URL(string: "comgooglemaps://?daddr=\(String(describing: coordinate.latitude)),\(String(describing: coordinate.longitude))")!)
            } else {
                UIApplication.shared.openURL(URL(string: "https://maps.google.com/?daddr=\(String(describing: coordinate.latitude)),\(String(describing: coordinate.longitude))")!)
            }
        }))
        actionController.addAction(Action(ActionData(title: "Tractor", image: UIImage(named: "user")!), style: .default, handler: { action in
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                UIApplication.shared.openURL(URL(string: "comgooglemaps://?daddr=\(String(describing: coordinate.latitude)),\(String(describing: coordinate.longitude))")!)
            } else {
                UIApplication.shared.openURL(URL(string: "https://maps.google.com/?daddr=\(String(describing: coordinate.latitude)),\(String(describing: coordinate.longitude))")!)
            }
        }))
        actionController.addAction(Action(ActionData(title: "Bicle", image: UIImage(named: "webSite")!), style: .default, handler: { action in
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                UIApplication.shared.openURL(URL(string: "comgooglemaps://?daddr=\(String(describing: coordinate.latitude)),\(String(describing: coordinate.longitude))")!)
            } else {
                UIApplication.shared.openURL(URL(string: "https://maps.google.com/?daddr=\(String(describing: coordinate.latitude)),\(String(describing: coordinate.longitude))")!)
            }
            
        }))
        
        present(actionController, animated: true, completion: nil)
    }
    
    @IBAction func Website_Function(_ sender: UIButton) {
        let pageIndex = SharedManager.sharedInstance.currentPageIndex
        let url = self.informations[pageIndex].webSiteURL
        if url != URL(fileURLWithPath: "") {
            UIApplication.shared.openURL(url.absoluteURL)
        }else {
            let alertController = UIAlertController(title: "Sorry!", message: "There are no WebSite URL, Please select other image.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                print("you have pressed the Cancel button");
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("you have pressed OK button");
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
        }
    }
    @IBAction func Call_Function(_ sender: UIButton) {
        
        let pageIndex = SharedManager.sharedInstance.currentPageIndex
        let phone = self.informations[pageIndex].phoneNumber
        print("phone number is \(phone)")
        
        //string paste
        let tempPhone = phone.components(separatedBy: " ")
        var really = String()
        for word in tempPhone {
            really.append(word)
        }
        
        print("phone number is \(really)")
        if really != "" {
            let url = URL(string: "tel://\(really)")
            UIApplication.shared.openURL(url!)
        
        }else {
            let alertController = UIAlertController(title: "Sorry!", message: "There are no Phone number, Please select other image.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                print("you have pressed the Cancel button");
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("you have pressed OK button");
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    //Save tag and coordinate in dropdown view
    @IBAction func Save_Function(_ sender: UIButton) {
        
        
    }
    @IBAction func TripAdvisor_Fucntion(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "https://www.tripadvisor.com")!)
    }
    
    @IBAction func RightSideAction(_ sender: UIButton) {
        if SharedManager.sharedInstance.currentPageIndex1 < self.photoArray.count - 1 {
            print("hhhhhhhhh \(self.photoArray.count)")
            print("hhhhhhhhh \(SharedManager.sharedInstance.currentPageIndex1)")
            let pagePlus = SharedManager.sharedInstance.currentPageIndex1 + 1
            self.photoView.carouselScrollView.setContentOffset(CGPoint.init(x: self.photoView.frame.width * CGFloat(pagePlus), y: 0.0) , animated: true)
            SharedManager.sharedInstance.currentPageIndex1 = pagePlus
            if self.informations.count > SharedManager.sharedInstance.currentPageIndex1 {
                self.nameLabel.text = self.informations[SharedManager.sharedInstance.currentPageIndex1].placeName
                self.addressLabel.text = self.informations[SharedManager.sharedInstance.currentPageIndex1].selectedAddress
            }
        }
        
    }
    
    @IBAction func LeftSideAction(_ sender: UIButton) {
        if SharedManager.sharedInstance.currentPageIndex1 > 0 {
            let pageMinus = SharedManager.sharedInstance.currentPageIndex1 - 1
            self.photoView.carouselScrollView.setContentOffset(CGPoint.init(x: self.photoView.frame.width * CGFloat(pageMinus), y: 0.0) , animated: true)
            SharedManager.sharedInstance.currentPageIndex1 = pageMinus
            if self.informations.count > SharedManager.sharedInstance.currentPageIndex1 {
                self.nameLabel.text = self.informations[SharedManager.sharedInstance.currentPageIndex1].placeName
                self.addressLabel.text = self.informations[SharedManager.sharedInstance.currentPageIndex1].selectedAddress
            }
            
        }
    }
    
    @IBAction func EditTagAction(_ sender: UIButton) {
        
        self.editTagView.isHidden = false
        self.creattagLabel.isHidden = false
        
        //remove all subviews of tagScroll3 scrollview
        let subViews = self.tagScroll3.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        self.tagScroll3.tags.removeAllObjects()
        
        animateWithTransition(.toTop)
        animateWithTransition_EditTag(.fromBottom)
        self.dropDown = false
        self.edit = true
    }
    @IBAction func SearchPlaceAction(_ sender: UIButton) {
        self.placeName_txt.endEditing(false)
        self.placeName_txt.isEnabled = true
        self.address_txt.isEnabled = true
    }
    
    //EditTag View function
    func animateWithTransition_EditTag(_ animator: AAViewAnimators) {
        self.editTagView.aa_animate(duration: 1.2, springDamping: .slight, animation: animator) { inAnimating in
            
            if inAnimating {
                print("Animating ....")
            }
            else {
                print("Animation Done")
            }
        }
    }

    
    //DropDown View function
    func animateWithTransition(_ animator: AAViewAnimators) {
        self.dropDownView.aa_animate(duration: 1.2, springDamping: .slight, animation: animator) { inAnimating in
            
            if inAnimating {
                print("Animating ....")
            }
            else {
                print("Animation Done")
            }
        }
    }
    
    // Populate the array with the list of likely places.
    func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()
        self.photoArray.removeAll()
        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
            if let error = error {
                // TODO: Handle the error.
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likely places and add to the list.
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    print("place is \(place)")
                    
                    self.placeIDString = place.placeID
                    if SharedManager.sharedInstance.currentPageIndex == 0 && SharedManager.sharedInstance.currentPageIndex1 == 0 {
                        self.nameLabel.text = place.name
                        self.addressLabel.text = place.formattedAddress
                    }
                    
                    let tempInformation: NSDictionary = ["phoneNumber": place.phoneNumber, "placeID": place.placeID, "webSiteURL": place.website, "Rate": place.rating, "selectedCoordinate": place.coordinate, "selectedAddress": place.formattedAddress, "placeName": place.name] as NSDictionary
                    let information: DropDownInformation = DropDownInformation.init(dictionary: tempInformation)
                    self.likelyPlaces.append(place)
                    self.loadFirstPhotoForPlace(placeID: self.placeIDString)
                    self.informations.append(information)
                }
                self.loadingView.hide()
                
            }
        })

    }
    
    func listLikelyPlaces1() {
        self.photoArray.removeAll()
        print("placeIDs is \(placeIDs)")
        print("placeID is \(placeIDs[self.selectIndex])")
        let placeid = placeIDs[self.selectIndex]
        placesClient.lookUpPlaceID(placeid, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(self.placeIDs[self.selectIndex])")
                return
            }
            
            if SharedManager.sharedInstance.currentPageIndex == 0 && SharedManager.sharedInstance.currentPageIndex1 == 0 {
                self.nameLabel.text = place.name
                self.addressLabel.text = place.formattedAddress
            }
            
            let tempInformation: NSDictionary = ["phoneNumber": place.phoneNumber, "placeID": place.placeID, "webSiteURL": place.website, "Rate": place.rating, "selectedCoordinate": place.coordinate, "selectedAddress": place.formattedAddress, "placeName": place.name] as NSDictionary
            let information: DropDownInformation = DropDownInformation.init(dictionary: tempInformation)
            self.likelyPlaces.append(place)
            self.loadFirstPhotoForPlace(placeID: self.placeIDString)
            self.informations.append(information)
        })
        loadingView.hide()
    }
    
    //obtaining photos from current location
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let locationPhotos = photos?.results.first {
                        self.loadImageForMetadata(photoMetadata: locationPhotos)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.photoArray.append(photo!)
                self.photoView.images = self.photoArray
            }
        })
    }
    
    //imageCarouselView delegate method
    public func scrolledToPage(_ page: Int) {
        let index = page//SharedManager.sharedInstance.currentPageIndex
        if self.informations.count > index {
            self.nameLabel.text = self.informations[index].placeName
            self.addressLabel.text = self.informations[index].selectedAddress
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //searched marker display
    func ShowMapView() {
        searchView.removeFromSuperview()
        self.mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(markerLatitude, markerLongitude), zoom: 12, bearing: 0, viewingAngle: 0)
        //self.setupLocationMarker(CLLocationCoordinate2DMake(markerLatitude, markerLongitude))
        let userMarker: GMSMarker!
        userMarker = GMSMarker(position: CLLocationCoordinate2DMake(markerLatitude, markerLongitude))
        userMarker.map = mapView
        
        userMarker.appearAnimation = GMSMarkerAnimation.pop
        usersMarker.append(userMarker)
        address_txt.endEditing(true)
        
    }
    
}

//TLTagsControl delegate method
extension MapViewController: TLTagsControlDelegate {
    
    func tagsControl(_ tagsControl: TLTagsControl!, tappedAt index: Int) {
        print("tag\(tagsControl.tags[index]) was tapped")
        if tagsControl == self.tagScroll4 {
            var tagBool = false
            for tag in self.tagScroll3.tags {
                if (tag as! String) == (tagsControl.tags[index] as! String) {
                    tagBool = true
                }
            }
            if !tagBool {
                self.tagScroll3.tags.add(tagsControl.tags[index])
                self.tagScroll3.mode = TLTagsControlMode.edit
                self.tagScroll3.tagPlaceholder = ""
                self.tagScroll3.tagsTextColor = UIColor.white
                self.tagScroll3.tagsDeleteButtonColor = UIColor.white
                self.tagScroll3.tagsbackgroundColor.add(tagsControl.tagsbackgroundColor[index])
                self.tagScroll3.reloadTagSubviews()
                self.tagScroll3.tapDelegate = self
                
                
                self.tagText = tagsControl.tags.object(at: index) as! String
                self.tagColor = tagsControl.tagsbackgroundColor.object(at: index) as! UIColor
                self.tagBool = true
                self.tag4Pressed = true
                
                self.addLabel.isHidden = true
                self.creattagLabel.isHidden = false
                self.inputtagName.text = ""
            }else {
                let alertController = UIAlertController(title: "Sorry!", message: "Your tag name was duplicated. Please input tag name again.", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("you have pressed OK button");
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion:nil)
            }
        }else if tagsControl == self.tagScroll1 {
            
            self.coordinateInfoArray.removeAll()
            for item in self.tagname_download {
                if item == (tagsControl.tags[index] as! String) {
                    
                    let eachTag = self.tagInformation_Download["\(item)"] as! NSDictionary
                    let eachTagCoordinate = eachTag["Coordinates"] as! [NSDictionary]
                    
                    for item1 in eachTagCoordinate {
                        self.coordinateInfoArray.append((item1["Coordinate"] as! String))
                    }
                }
            }
            
            self.displayOtherLocation()
        }else if tagsControl == self.tagScroll2 {
            
            self.coordinateInfoArray.removeAll()
            for item in self.tagname_download {
                if item == (tagsControl.tags[index] as! String) {
                    
                    let eachTag = self.tagInformation_Download["\(item)"] as! NSDictionary
                    let eachTagCoordinate = eachTag["Coordinates"] as! [NSDictionary]
                    
                    for item1 in eachTagCoordinate {
                        self.coordinateInfoArray.append((item1["Coordinate"] as! String))
                    }
                }
            }
            
            self.displayOtherLocation()
        }
    }
    
    func tagsControl(_ tagsControl: TLTagsControl!, removedAt index: Int) {
        print("tag\(tagsControl.tags[index]) was deleted")
        
        let tempuserName = SharedManager.sharedInstance.emailText
        
        if tagsControl == self.tagScroll1 {
            self.ref.child("Caledonia").child("\(tempuserName)").child("TagInformation").child("\(tagsControl.tags[index] as! String)").child("Coordinates").removeValue()
        }else if tagsControl == self.tagScroll2 {
            self.ref.child("Caledonia").child("\(tempuserName)").child("TagInformation").child("\(tagsControl.tags[index] as! String)").child("Coordinates").removeValue()
        }else if tagsControl == self.tagScroll4 {
            self.ref.child("Caledonia").child("\(tempuserName)").child("TagInformation").child("\(tagsControl.tags[index] as! String)").child("Coordinates").removeValue()
        }
    }
}

//searchTableView delegate and datasource method.
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(searchResult[indexPath.row])
        address_txt.text = searchResult[indexPath.row]
        self.selectIndex = indexPath.row
        self.searchView.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")
        cell?.textLabel?.text = searchResult[indexPath.row]
        cell?.textLabel?.font = UIFont.init(name: "", size: 15)
        cell?.contentView.backgroundColor = UIColor.clear
        
        return cell!
    }
}

//GMSMapViewDelegate method
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        //marker coordinates
        self.coordinates = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        
        if self.coordinates.latitude == SharedManager.sharedInstance.currentLoc.latitude && self.coordinates.longitude == SharedManager.sharedInstance.currentLoc.longitude {
            self.informations.removeAll()
            listLikelyPlaces()
            self.filterTag.isHidden = true
            self.dropDownView.isHidden = false
            animateWithTransition(.fromTop)
            self.dropDown = true
            print("information of count is \(self.informations.count)")
            
            //RSLoading View display
            loadingView.show(on: view)

        }else {
            self.informations.removeAll()
            listLikelyPlaces1()
            self.filterTag.isHidden = true
            self.dropDownView.isHidden = false
            animateWithTransition(.fromTop)
            self.dropDown = true
            print("information of count is \(self.informations.count)")
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if self.dropDown {
            animateWithTransition(.toTop)
            self.photoArray.removeAll()
            self.dropDown = false
        }else if self.edit {
            animateWithTransition_EditTag(.toBottom)
            self.edit = false
        }
    }
}



extension MapViewController: CLLocationManagerDelegate {
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            locationManager.stopUpdatingLocation()
        }
    }

}

