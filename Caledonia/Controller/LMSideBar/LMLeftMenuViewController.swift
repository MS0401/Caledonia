//
//  LMLeftMenuViewController.swift
//  VocalRecording
//
//  Created by dev on 2/23/17.
//  Copyright © 2017 dev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class LMLeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //The Titles of Side bar.
    var menuTitles = [0: "Profile", 1: "Friends", 2: "Messages", 3: "Notifications", 4: "Settings",5: "Help"]
    //The images of Side bar.
    var cellimage = [0: "profile1.png", 1: "friends1.png", 2: "message1.png", 3: "notification1.png", 4: "setting1.png", 5:"help1.png"]
    
    //initialize.
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var toolBar_left: UIToolbar!
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Firebase reference path
        self.ref = Database.database().reference()
        
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
                    
                    
                    self.avatarImageView.image = image
                    self.CircleImage(profileImage: self.avatarImageView!)
                }else {
                    self.avatarImageView.image = UIImage(named: "profileImage")
                    self.CircleImage(profileImage: self.avatarImageView!)
                }
                
            }
        })
       
        self.tableView.register(UINib(nibName: "LelfMenuViewCell", bundle: nil), forCellReuseIdentifier: "LM")
        
    }
    
    //making circle image
    func CircleImage(profileImage: UIImageView) {
        // Circle images
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderWidth = 0.5
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func RemoveMenu(_ sender: Any) {
        self.sideBarController.hideMenuViewController(true)
    }
    // Table View DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "LM", for: indexPath) as! LelfMenuViewCell
        cell.titleLabel.text = self.menuTitles[indexPath.row]
        cell.titleLabel.textColor = UIColor(white: 0.0, alpha: 1)
        cell.backgroundColor = UIColor.clear
        cell.cellImage.image = UIImage(named: cellimage[indexPath.row]!)
        return cell
    }
    
    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage{
        
        
        let scale = CGFloat(max(size.width/image.size.width,
                                size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        
        let rr:CGRect = CGRect( x:0, y:0, width:width, height:height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
    // TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
}
