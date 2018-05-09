//
//  NewPlaceViewController.swift
//  Caledonia
//
//  Created by For on 6/27/17.
//  Copyright © 2017 For. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NewPlaceViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Firebase reference path
        self.ref = Database.database().reference()

        self.DownloadProfileImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.DownloadProfileImage()
    }
    
    func DownloadProfileImage() {
        
        var imageURL: String!
        
        //download image URL from Firebase
        self.ref.child("Caledonia").observe(DataEventType.value, with: { snapshot in
            for item in snapshot.children {
                print("item is \(item)")
                let child = item as! DataSnapshot
                let dict = child.value as! NSDictionary
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
                
                
            }
        })

    }
    
    //making circle image
    func CircleImage(profileImage: UIImageView) {
        // Circle images
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderWidth = 0.5
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true
        
    }
    
}
