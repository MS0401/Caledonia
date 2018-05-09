//
//  TagInformation.swift
//  Caledonia
//
//  Created by For on 6/22/17.
//  Copyright © 2017 For. All rights reserved.
//

import Foundation
import UIKit

class TagInformation {
    
    var tagText: String
    var tagColor: String
    var tagLocations: Location
    
    init() {
        self.tagText = ""
        self.tagColor = ""
        self.tagLocations = Location.init()
    }
    
    init(tagText: String, tagColor: String, tagLocations: Location) {
        self.tagText = tagText
        self.tagColor = tagColor
        self.tagLocations = tagLocations
    }
    
    convenience init(dictionary: NSDictionary) {
        
        let tagText = dictionary["tagText"] as? String != nil ? dictionary["tagText"] as! String : ""
        let tagColor = dictionary["tagColor"] as? String != nil ? dictionary["tagColor"] as! String : ""
        let tagLocations = dictionary["tagLocations"] as? Location != nil ? dictionary["tagLocations"] as! Location : Location.init(Coordinate: [String].init(), placeName: "")
        
        self.init(tagText: tagText, tagColor: tagColor, tagLocations: tagLocations)
    }
    
}
