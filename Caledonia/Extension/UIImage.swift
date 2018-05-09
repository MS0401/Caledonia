//
//  UIImage.swift
//  Caledonia
//
//  Created by For on 6/26/17.
//  Copyright © 2017 For. All rights reserved.
//

import Foundation

extension UIImage {
    
    // Cirecle image
    var circle: UIImageView {
        
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        //        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(netHex: 0x666666).cgColor
        imageView.layer.borderWidth = 0.3
        
        //        UIGraphicsBeginImageContext(imageView.bounds.size)
        //        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        //
        //        let result = UIGraphicsGetImageFromCurrentImageContext()
        //        UIGraphicsEndImageContext()
        
        return imageView
    }
}
