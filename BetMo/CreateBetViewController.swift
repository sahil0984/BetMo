//
//  CreateBetViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/9/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class CreateBetViewController: UIViewController {

    @IBOutlet weak var currUserNameLabel: UILabel!
    @IBOutlet weak var currUserImageView: UIImageView!
    
    @IBOutlet weak var vsUserNameTextField: UITextField!
    @IBOutlet weak var vsUserImageView: UIImageView!
    
    @IBOutlet weak var betOnLabel: UITextView!
    @IBOutlet weak var betAmountLabel: UITextField!
    
    
    var currUser = User()
    var vsUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.currUser = PFUser.currentUser() as User
        
        var firstName = self.currUser["firstName"] as? String
        var lastName = self.currUser["lastName"] as? String
        self.currUserNameLabel.text = "\(firstName!) \(lastName!)"
        
        var urlRequest = NSURLRequest(URL: NSURL(string: (self.currUser["profileImageUrl"] as String)))
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
            if connectionError == nil && data != nil {
                self.currUserImageView.image = UIImage(data: data!)
            }
        }
        
        self.betOnLabel.text = "Describe your bet..."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreateButton(sender: AnyObject) {
        var newBet = Bet()
        
        newBet["owner"] = currUser as User
        newBet["description"] = betOnLabel.text as String
        if vsUserNameTextField.text != "" {
            newBet["opponent"] = vsUser as User
        }
        newBet["amount"] = betAmountLabel.text as String
        newBet["isAccepted"] = false
        
        newBet.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                println("Successfully created bet");
            } else {
                println("Failed creating the bet");
                println("\(error!)")
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBAction func onTouchVsUser(sender: AnyObject) {
        println("text field touched")
        self.performSegueWithIdentifier("friendsListSegue", sender: self)
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
