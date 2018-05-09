//
//  SignUpViewController.swift
//  Caledonia
//
//  Created by For on 6/28/17.
//  Copyright © 2017 For. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import RSLoadingView

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    //Loading View property
    let loadingView = RSLoadingView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Sign Up Action for email
    @IBAction func Save(_ sender: UIButton) {
        
        if emailText.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            
            self.loadingView.show(on: view)
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    
                    self.performSegue(withIdentifier: "signupEmail", sender: self)
                    self.loadingView.hide()
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    self.loadingView.hide()
                }
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signupEmail" {
            _ = segue.destination as! LMRootViewController
            //login.first = false
            
            let emailtxt = self.emailText.text!
            let temp = emailtxt.components(separatedBy: "@")
            let reallytxt = temp.first
            SharedManager.sharedInstance.emailText =  reallytxt!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }



    
}
