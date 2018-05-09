//
//  ProfileViewController.swift
//  Caledonia
//
//  Created by For on 6/27/17.
//  Copyright © 2017 For. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RSLoadingView

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followings: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var seeMap: UIButton!
    
    var ref: DatabaseReference!
    var imagePicker: UIImagePickerController = UIImagePickerController()
    let loadingView = RSLoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Firebase reference path
        self.ref = Database.database().reference()

        self.loadingView.show(on: view)
        self.DownloadProfileImage()
        
        self.imagePicker.delegate = self
        self.CircleImage(profileImage: profileImage)

        self.seeMap.layer.borderWidth = 1
        self.seeMap.layer.borderColor = UIColor.gray.cgColor
        self.seeMap.layer.shadowColor = UIColor.black.cgColor
        self.seeMap.layer.shadowOpacity = 0.16
        self.seeMap.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.seeMap.layer.cornerRadius = seeMap.frame.size.height / 2

    }
    
    //Download Profile Image
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
                    
                    self.loadingView.hide()
                }else {
                    self.profileImage.image = UIImage(named: "profileImage")
                    self.CircleImage(profileImage: self.profileImage!)
                    self.loadingView.hide()
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

    @IBAction func ImagePicker(_ sender: UIButton) {
        
        self.imagePicker.allowsEditing = false
        self.imagePicker.delegate = self
        self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.imagePicker.modalPresentationStyle = .popover
        self.imagePicker.sourceType = .photoLibrary// or savedPhotoAlbume
        self.present(self.imagePicker, animated: true, completion: nil)

    }
    
    // UIImagePickerControllerDelegate Mehtods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage.backgroundColor = UIColor.clear
            self.profileImage.image = pickedImage
            self.CircleImage(profileImage: self.profileImage)
            
            self.UploadingImageURL()
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func UploadingImageURL() {
        
        //getting image URL from library or photoAlbum.
        var data: NSData = NSData()
        if let image = self.profileImage.image {
            data = UIImageJPEGRepresentation(image, 0.1)! as NSData
        }
        let imageURL = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        
        let url = imageURL
        let userName = SharedManager.sharedInstance.emailText
        let child = ["Caledonia/\(userName)/ProfileImage/profileImage/userImage": url]
        self.ref.updateChildValues(child)
        
    }
    
    @IBAction func Edit(_ sender: UIButton) {
    }
    
    @IBAction func Back(_ sender: UIButton) {
    }
    
    @IBAction func SeeMap(_ sender: UIButton) {
    }
    
    @IBAction func SideView(_ sender: UIButton) {
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
