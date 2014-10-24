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

class CreateBetViewController: UIViewController, UITextViewDelegate {

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
    
    let betDefaultText = "Describe your bet..."
    var betTextLength = 0
    
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
        
        self.betOnLabel.delegate = self
        self.betOnLabel.text = ""
        AddEmptyBetHint()
        betTextLength = 0
        //self.betOnLabel.text = "Describe your bet..."
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
        
        newBet.create()
        
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
    
    func AddEmptyBetHint() {
        var betTextLength = betOnLabel.text as NSString
        if betTextLength.length == 0 {
            betOnLabel.text = betDefaultText
            setHintFont()
        }
    }
    
    
    func textViewDidChange(textView: UITextView) {
        var betText = betOnLabel.text as NSString
        betTextLength = betText.length
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        setBetFont()
        
        if betTextLength == 0 {
            betOnLabel.text = ""
        }
        return true
    }
    
    func setHintFont() {
        //newTweet.font = UIFont(name: newTweetFont.fontName, size: 14)
        betOnLabel.textColor = UIColor.grayColor()
        //newTweet.toggleItalics(self)
    }
    func setBetFont() {
        //newTweet.font = UIFont(name: newTweetFont.fontName, size: 14)
        //newTweet.toggleItalics(self)
        betOnLabel.textColor = UIColor.blackColor()
    }
    
    @IBAction func onTapView(sender: UITapGestureRecognizer) {
        view.endEditing(true)
        
        AddEmptyBetHint()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var friendsListViewController = segue.destinationViewController as FriendsListViewController
        
        //friendsListViewController.delegate = self
    }


}
