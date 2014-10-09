//
//  ViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    

    @IBAction func onLoginButton(sender: AnyObject) {
        
        if PFUser.currentUser() == nil {
            
            println("Login new user")
        
            var permissions: [String] = ["email"]
            
            PFFacebookUtils.logInWithPermissions(permissions, {
                (user: PFUser!, error: NSError!) -> Void in
                if user == nil {
                    NSLog("Uh oh. The user cancelled the Facebook login.")
                } else if user.isNew {
                    NSLog("User signed up and logged in through Facebook!")
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                } else {
                    NSLog("User logged in through Facebook!")
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                }
            })
            
        } else {
            
            if !PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
                println("Attempting to Link current user")
                PFFacebookUtils.linkUser(PFUser.currentUser(), permissions:nil, {
                    (succeeded: Bool!, error: NSError!) -> Void in
                    if succeeded ?? false {
                        NSLog("Woohoo, user logged in with Facebook!")
                        println("Linked current user")
                        self.performSegueWithIdentifier("loginSegue", sender: self)
                    } else {
                        println("Error linking current user")
                    }
                })
            } else {
                println("Current user already linked")
                self.performSegueWithIdentifier("loginSegue", sender: self)
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

