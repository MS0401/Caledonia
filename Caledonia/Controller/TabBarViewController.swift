//
//  TabBarViewController.swift
//  Caledonia
//
//  Created by For on 6/15/17.
//  Copyright © 2017 For. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    public var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var homViewController: MapViewController!
    var othersViewController: LMOtherViewController!
    
    var first: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.layer.shadowColor = UIColor.black.cgColor
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func homeViewController() -> MapViewController {
        if homViewController != nil {
            homViewController = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        }
        
        return homViewController
        
    }
    
//    func OthersViewController() -> LMOtherViewController {
//        
//        if othersViewController != nil {
//            
//            othersViewController = self.storyboard?.instantiateViewController(withIdentifier: "othersViewController") as! LMOtherViewController!
//        }
//        
//        return othersViewController
//    }
//
    
    func showHomeViewController(){
        
        self.setViewControllers([self.homViewController], animated: true)
    }
    
//    func showOthersViewController(){
//        
//        self.setViewControllers([self.othersViewController], animated: true)
//    }


}
