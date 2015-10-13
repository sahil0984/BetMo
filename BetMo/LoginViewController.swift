//
//  ViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }


    @IBAction func onLoginButton(sender: AnyObject) {
        
        print("Login new user")
        
        let permissions: [String] = ["email", "user_friends"]
        
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("User logged in through Facebook!")
                }
                self.gotoHomeViewController()
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
        
        
    }
    
    
    func gotoHomeViewController() {
        self.performSegueWithIdentifier("loginSegue", sender: self)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

