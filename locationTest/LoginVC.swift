//
//  LoginVC.swift
//  locationTest
//
//  Created by Adriana González on 9/7/16.
//  Copyright © 2016 Adriana Gonzalez. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func asRangerPressed(_ sender: AnyObject) {
        Singleton.sharedInstance.asRanger = true
    }
    
    @IBAction func asHQPressed(_ sender: AnyObject) {
        Singleton.sharedInstance.asRanger = false
    }
}
