//
//  Location.swift
//  Caledonia
//
//  Created by For on 6/22/17.
//  Copyright © 2017 For. All rights reserved.
//

import Foundation
import UIKit

class Location {
    
    var Coordinate: [String]
    var placeName: String
    
    init() {
        self.Coordinate = [String].init()
        self.placeName = ""
    }
    
    init(Coordinate: [String], placeName: String) {
        self.Coordinate = Coordinate
        self.placeName = placeName
    }
    
    convenience init(dictionary: NSDictionary) {
        let coordinate = dictionary["Coordinate"] as? [String] != nil ? dictionary["Coordinate"] as! [String] : [String].init()
        let placeName = dictionary["placeName"] as? String != nil ? dictionary["placeName"] as! String : ""
        
        self.init(Coordinate: coordinate, placeName: placeName)
    }
}
