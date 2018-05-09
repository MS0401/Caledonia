//
//  SharedManager.swift
//  DazzlePanel
//
//  Created by For on 5/29/17.
//  Copyright © 2017 For. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class SharedManager {
    
    static let sharedInstance = SharedManager()
    
    //user token information
    var token: String = ""
    
    //Login information
    var loginUser = ""
    var emailText = ""
    
    //Marker location
    var markerLocation = ""
    
    //Current location
    var currentLocation = ""
    var currentLoc: CLLocationCoordinate2D!
    
    //Destination location
    var destinationLocation = ""
    var destinationLoc: CLLocationCoordinate2D!
    
    // Refresh State
    var isRefreshed = true
    var isUpdated = true
    // FaceBook personal information
    var tempData: [String : AnyObject]!
    var isLogin: Bool = false
    
    //selected photo of current image index
    var currentPageIndex: Int = 0
    var currentPageIndex1: Int = 0
}
