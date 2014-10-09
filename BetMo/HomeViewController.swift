//
//  HomeViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(sender: AnyObject) {

        NSNotificationCenter.defaultCenter().postNotificationName("userDidLogoutNotification", object: nil)
    }

    
    

    
    
    
    //TODO: Need to figure out a better place to do this in order to slim down this controller
    func loadUserData() {
        var request = FBRequest.requestForMe()
        request.startWithCompletionHandler { (connection, result, error: NSError?) -> Void in
            if error == nil {
                var userData = result as NSDictionary
                
                var fbId = userData["id"] as String
                var firstName = userData["first_name"] as String
                var lastName = userData["last_name"] as String
                var email = userData["email"] as String
                var profileImageUrl = "https://graph.facebook.com/\(fbId)/picture?type=large&return_ssl_resources=1" as String
                
                var currUser = PFUser.currentUser()
                currUser["fbId"] = fbId
                currUser["firstName"] = firstName
                currUser["lastName"] = lastName
                currUser["email"] = email
                currUser["profileImageUrl"] = profileImageUrl
                currUser.saveInBackground()
  
            } else {
                println("Facebook request error: \(error)")
            }
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
