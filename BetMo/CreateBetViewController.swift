//
//  CreateBetViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/9/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol CreateBetViewControllerDelegate {
    func createdBet(betCreated : Bet) -> Void
}

class CreateBetViewController: UIViewController, FriendsListViewControllerDelegate {

    @IBOutlet weak var currUserNameLabel: UILabel!
    @IBOutlet weak var currUserImageView: UIImageView!
    
    @IBOutlet weak var vsUserNameTextField: UITextField!
    @IBOutlet weak var vsUserImageView: UIImageView!
    
    @IBOutlet weak var betOnLabel: UITextView!
    @IBOutlet weak var betAmountLabel: UITextField!
    
    var currUser = User()
    var vsUser = User()
    
    var newBet: Bet = Bet()
    var delegate: CreateBetViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.currUser = PFUser.currentUser() as User

        self.currUserNameLabel.text = "\(self.currUser.getName())"
        
        var urlRequest = NSURLRequest(URL: NSURL(string: (self.currUser.getProfileImageUrl())!))
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
        newBet = Bet()
        
        var winnerUser = User()
        
        newBet.setOwner(currUser as User)
        newBet.setDescription(betOnLabel.text as String)
        if vsUserNameTextField.text != "" {
            newBet.setOpponent(vsUser as User)
        }
        newBet.setAmount(betAmountLabel.text as String)
        newBet.setIsAccepted(false)
        
        newBet.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                println("Successfully created bet");
            } else {
                println("Failed creating the bet");
                println("\(error!)")
            }
        }
        
        delegate?.createdBet(newBet)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBAction func onTouchVsUser(sender: AnyObject) {
        println("text field touched")
        
        self.performSegueWithIdentifier("friendsListSegue", sender: self)
    }
    
    func friendSelected(selectedFriend: User) {
        self.vsUser = selectedFriend
        self.vsUserNameTextField.text = selectedFriend.getName()
        
        var urlRequest = NSURLRequest(URL: NSURL(string: (self.vsUser.getProfileImageUrl())!))
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
            if connectionError == nil && data != nil {
                self.vsUserImageView.image = UIImage(data: data!)
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var friendsListViewController = segue.destinationViewController as FriendsListViewController
        
        friendsListViewController.delegate = self
    }


}
