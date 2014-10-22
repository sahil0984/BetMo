//
//  AddBetViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit


protocol AddBetViewControllerDelegate {
    func createdBet(betCreated : Bet) -> Void
}

class AddBetViewController: UIViewController, UITextViewDelegate, FriendsListViewControllerDelegate {

    
    @IBOutlet weak var betDescView: UITextView!
    @IBOutlet weak var betDescTextViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var betAmountView: UIView!
    @IBOutlet weak var betAmountLabel: UILabel!
    @IBOutlet weak var betAmountSlider: UISlider!
    @IBOutlet weak var betAmountSliderHeight: NSLayoutConstraint!
    
    @IBOutlet weak var friendsListContainer: UIView!
    
    @IBOutlet weak var descCharCountLabel: UILabel!
    
    var creationStep = 0
    
    let betDefaultText = "Describe your bet..."
    var betTextLength = 0
    
    var friendsListViewController: FriendsListViewController!
    var selectedOpponent: User?
    
    var delegate: AddBetViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        betAmountView.hidden = true
        betAmountView.backgroundColor = UIColor.whiteColor()
        
        friendsListContainer.hidden = true
        friendsListContainer.backgroundColor = UIColor.whiteColor()
        
        self.betDescView.delegate = self
        self.betDescView.text = ""
        AddEmptyBetHint()
        betTextLength = 0
        
        friendsListViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendsListViewController") as? FriendsListViewController
        friendsListViewController.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func friendSelected(selectedFriend: User) {
        self.selectedOpponent = selectedFriend
    }
    
    
    @IBAction func onDone(sender: AnyObject) {
        if creationStep == 0 { //Show amount stuff
            
            betAmountView.frame.origin.y = view.frame.height
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.betAmountView.frame.origin.y = self.betDescView.frame.origin.y + self.betDescView.frame.height
            }, completion: { (finished) -> Void in
                
            })
            
            var textViewHeight = betDescView.sizeThatFits(betDescView.frame.size).height
            println(textViewHeight)
            betDescTextViewHeight.constant = textViewHeight
            
            
            betDescView.editable = false
            betAmountView.hidden = false
            creationStep += 1
            
        } else if creationStep == 1 { //show pick friend stuff
            
            friendsListContainer.frame.origin.y = view.frame.height
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.friendsListContainer.frame.origin.y = self.betAmountView.frame.origin.y + self.betAmountView.frame.height
                }, completion: { (finished) -> Void in
                    
            })
            
            //Adding a new viewController to the parent
            self.addChildViewController(self.friendsListViewController) //viewWillAppear + rotate call
            self.friendsListViewController.view.frame = self.friendsListContainer.bounds
            self.friendsListContainer.addSubview(self.friendsListViewController.view)
            self.friendsListViewController.didMoveToParentViewController(self) //viewDidAppear
            
            friendsListContainer.hidden = false
            betAmountSlider.hidden = true
            betAmountSliderHeight.constant = 0
            
            creationStep += 1
        } else if creationStep == 2 { //create final bet
            
            var currentUser = PFUser.currentUser() as User
            var newBet = Bet()
            newBet.setOwner(currentUser)
            newBet.setDescription(betDescView.text)
            
            var amountLabel = betAmountLabel.text
            var parsedAmount = amountLabel?.stringByReplacingOccurrencesOfString("$", withString: "")
            newBet.setAmount(parsedAmount!)
            newBet.setIsAccepted(false)
            if let opponent = selectedOpponent {
                newBet.setOpponent(opponent)
            }
            
            newBet.create()
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            delegate?.createdBet(newBet)
        }
    }
    
    @IBAction func onAmountSlider(sender: UISlider) {
        var betAmount:Int = Int(100 * sender.value / 5)
        betAmountLabel.text = "$\(betAmount * 5)"
    }
    
    
    //Logic for managing hint text and char count:
    //------------------------------------------------
//    @IBAction func onTapOutside(sender: UITapGestureRecognizer) {
//        view.endEditing(true)
//        AddEmptyBetHint()
//    }
    
    func AddEmptyBetHint() {
        var betTextLength = betDescView.text as NSString
        if betTextLength.length == 0 {
            betDescView.text = betDefaultText
            setHintFont()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        var betText = betDescView.text as NSString
        betTextLength = betText.length
        
        descCharCountLabel.text = "\(140 - betTextLength)"
        if betTextLength > 140 {
            descCharCountLabel.textColor = UIColor.redColor()
        } else {
            descCharCountLabel.textColor = UIColor.blackColor()
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        setBetFont()
        
        if betTextLength == 0 {
            betDescView.text = ""
        }
        return true
    }
    
    func setHintFont() {
        //newTweet.font = UIFont(name: newTweetFont.fontName, size: 14)
        betDescView.textColor = UIColor.grayColor()
        //newTweet.toggleItalics(self)
    }
    func setBetFont() {
        //newTweet.font = UIFont(name: newTweetFont.fontName, size: 14)
        //newTweet.toggleItalics(self)
        betDescView.textColor = UIColor.blackColor()
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
