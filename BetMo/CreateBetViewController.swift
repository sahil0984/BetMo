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
    
    @IBOutlet weak var vsUserNameLabel: UITextField!
    @IBOutlet weak var vsUserImageView: UIImageView!
    
    @IBOutlet weak var betOnLabel: UITextView!
    @IBOutlet weak var betAmountLabel: UITextField!
    
    
    var currUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.currUser = PFUser.currentUser() as User

        self.currUserNameLabel.text = "\(self.currUser.getName())"
        
        var urlRequest = NSURLRequest(URL: NSURL(string: (self.currUser.getProfileImageUrl())))
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
        
        var vsUser = User()
        var winnerUser = User()
        
        newBet.setOwner(currUser as User)
        newBet.setDescription(betOnLabel.text as String)
        newBet.setOpponent(vsUser as User)
        newBet.setAmount(betAmountLabel.text as String)
        newBet.setWinner(winnerUser as User)
        newBet.setIsAccepted(false)
        
        newBet.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                println("Success saving bet");
                println("\(error!)")
            } else {
                println("Failed saving bet");
                println("\(error!)")
            }
        }
    }

    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
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
