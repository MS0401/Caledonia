//
//  DropDownInformation.swift
//  Caledonia
//
//  Created by For on 6/19/17.
//  Copyright © 2017 For. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class DropDownInformation {
    
    static let sharedInstance = DropDownInformation()
    
    //PhoneNumber
    var phoneNumber: String
    
    //placeID
    var placeID: String
    
    //website url
    var webSiteURL: URL
    
    var Rate: Float
   
    //seclected coordinate
    var selectedCoordinate: CLLocationCoordinate2D
    
    //formatted address
    var selectedAddress: String
    
    //place name
    var placeName: String
    
    //photo image
    //var photoImage: UIImage
    
    init() {
        self.phoneNumber = ""
        self.placeID = ""
        self.selectedCoordinate = CLLocationCoordinate2D.init()
        self.selectedAddress = ""
        self.placeName = ""
        self.Rate = 0.0
        self.webSiteURL = URL(string: "")!
        
    }
    
    init(phoneNumber: String, placeID: String, webSiteURL: URL, Rate: Float, selectedCoordinate: CLLocationCoordinate2D, selectedAddress: String, placeName: String) {
        self.phoneNumber = phoneNumber
        self.placeID = placeID
        self.webSiteURL = webSiteURL
        self.Rate = Rate
        self.selectedCoordinate = selectedCoordinate
        self.selectedAddress = selectedAddress
        self.placeName = placeName
        
    }
    
    convenience init(dictionary: NSDictionary) {
        
        let phoneNumber = dictionary["phoneNumber"] as? String != nil ? dictionary["phoneNumber"] as! String : ""
        let placeID = dictionary["placeID"] as? String != nil ? dictionary["placeID"] as! String : ""
        let webSiteURL = dictionary["webSiteURL"] as? URL != nil ? dictionary["webSiteURL"] as! URL : URL(fileURLWithPath: "")
        let Rate = dictionary["Rate"] as? Float != nil ? dictionary["Rate"] as! Float : 0.0
        let selectedCoordinate = dictionary["selectedCoordinate"] as! CLLocationCoordinate2D
        let selectedAddress = dictionary["selectedAddress"] as? String != nil ? dictionary["selectedAddress"] as! String : ""
        let placeName = dictionary["placeName"] as? String != nil ? dictionary["placeName"] as! String : ""
        
        
        self.init(phoneNumber: phoneNumber, placeID: placeID, webSiteURL: webSiteURL, Rate: Rate, selectedCoordinate: selectedCoordinate, selectedAddress: selectedAddress, placeName: placeName)
    }
}
