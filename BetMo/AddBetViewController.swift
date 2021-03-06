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
    
    //constriants
    @IBOutlet weak var createBetTopMargin: NSLayoutConstraint!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var creationStep = 0
    
    let betDefaultText = "Describe your bet..."
    var betDescTextLength = 0
    
    var friendsListViewController: FriendsListViewController!
    var selectedOpponent: User?
    var isFriendSelected: Bool = false
    
    var delegate: AddBetViewControllerDelegate?
    
    
    //animation constants:
    var createBetTopMarginAnimateByY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        betAmountView.hidden = true
        betAmountView.backgroundColor = UIColor.whiteColor()
        betAmountLabel.text = "$25"
        betAmountSlider.value = (25 * 5 / 1000) / 5

        
        friendsListContainer.hidden = true
        friendsListContainer.backgroundColor = UIColor.whiteColor()
        
        betAmountSlider.setThumbImage(UIImage(named: "money_slider"), forState: UIControlState.Normal)
        
        self.betDescView.delegate = self
        self.betDescView.text = ""
        AddEmptyBetHint()
        betDescTextLength = 0
        
        cancelButton.titleLabel?.text = "Cancel"
        doneButton.titleLabel?.text = "Next"
        
        friendsListViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendsListViewController") as? FriendsListViewController
        friendsListViewController.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onDone(sender: AnyObject) {
        if creationStep == 0 { //Show amount stuff
            
            if betDescTextLength > 140 || betDescTextLength == 0 {
                
                let descFontColor = descCharCountLabel.textColor
                UIView.transitionWithView(descCharCountLabel, duration: 0.25, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    self.descCharCountLabel.textColor = UIColor.greenColor()
                }, completion: { (finished) -> Void in
                    
                    UIView.transitionWithView(self.descCharCountLabel, duration: 0.25, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                        self.descCharCountLabel.textColor = descFontColor
                    }, completion: { (finished) -> Void in
                        self.descCharCountLabel.textColor = descFontColor
                    })
                    self.descCharCountLabel.textColor = descFontColor
                })
                
            } else {
            
                animateBetAmountIn()
                
                creationStep += 1
            }
            
        } else if creationStep == 1 { //show pick friend stuff
            
            friendsListContainer.frame.origin.y = view.frame.height
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.friendsListContainer.frame.origin.y = self.betAmountView.frame.origin.y + self.betAmountView.frame.height
                //self.friendsListContainer.frame.origin.y = 0
                }, completion: { (finished) -> Void in
                    
            })
            
            animateFriendListStartEdit()
            
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
            
            if isFriendSelected {
                let currentUser = PFUser.currentUser() as! User
                let newBet = Bet()
                newBet.setOwner(currentUser)
                newBet.setDescription(betDescView.text)
                
                let amountLabel = betAmountLabel.text
                let parsedAmount = amountLabel?.stringByReplacingOccurrencesOfString("$", withString: "")
                newBet.setAmount(parsedAmount!)
                newBet.setIsAccepted(false)
//                if let opponent = selectedOpponent {
//                    newBet.setOpponent(opponent)
//                }
                if selectedOpponent?.getFirstName() != "Open Bet" {
                    newBet.setOpponent(selectedOpponent!)
                }
                
                newBet.create()
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
                delegate?.createdBet(newBet)
            }

        }
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        if creationStep == 0 {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else if creationStep == 1 {
            //animateBetAmountOut
            cancelButton.titleLabel?.text = "Cancel"
            doneButton.titleLabel?.text = "Next"
            creationStep -= 1
        } else if creationStep == 2 {
            //animateFriendsListOut
            cancelButton.titleLabel?.text = "Back"
            doneButton.titleLabel?.text = "Next"
            creationStep -= 1
        }
        
    }
    
    @IBAction func onAmountSlider(sender: UISlider) {
        let betAmount:Int = Int(1000 * sender.value / 5)
        betAmountLabel.text = "$\(betAmount * 5)"
    }
    
    @IBAction func onTouchAmountLabel(sender: UITapGestureRecognizer) {

    }
    
    //Logic for managing hint text and char count:
    //------------------------------------------------
    func AddEmptyBetHint() {
        let betTextLength = betDescView.text as NSString
        if betTextLength.length == 0 {
            betDescView.text = betDefaultText
            setHintFont()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let betText = betDescView.text as NSString
        betDescTextLength = betText.length
        
        descCharCountLabel.text = "\(140 - betDescTextLength)"
        if betDescTextLength > 140 {
            descCharCountLabel.textColor = UIColor.redColor()
        } else {
            descCharCountLabel.textColor = UIColor.blackColor()
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        setBetFont()
        
        if betDescTextLength == 0 {
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
    
    func friendSelected(selectedFriend: User) {
        self.selectedOpponent = selectedFriend
        
        animateFriendListEndEdit()
        
        isFriendSelected = true
    }
    
    
    func friendListEditChanged(state: Int) {
        animateFriendListStartEdit()
        
        isFriendSelected = false
    }
    
    //Animating various components of bet creation flow:
    func animateBetAmountIn() {
        
        //Make TextView take occupy height that it needs to fit content
        let textViewHeight = betDescView.sizeThatFits(betDescView.frame.size).height
        betDescTextViewHeight.constant = textViewHeight
        
        //Set descriptionView to not editable
        betDescView.editable = false
        
        //Animate AmountView in
        betAmountView.frame.origin.y = view.frame.height
        betAmountView.hidden = false
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.betAmountView.frame.origin.y = self.betDescView.frame.origin.y + self.betDescView.frame.height
        }, completion: { (finished) -> Void in
                
        })
    }
    
    //Animate select friend start edit
    func animateFriendListStartEdit() {
        
        createBetTopMarginAnimateByY = 0 - self.betAmountView.frame.origin.y - 20

        //Animate description and amount out of the view
        UIView.animateWithDuration(0.5, animations: { () -> Void in

            self.createBetTopMargin.constant = self.createBetTopMarginAnimateByY
            self.view.layoutIfNeeded()

        }, completion: { (finished) -> Void in
            
        })
        
        //CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size
        
    }
    
    //Animate select friend end edit
    func animateFriendListEndEdit() {

        createBetTopMarginAnimateByY = 20
        
        //Animate description and amount out of the view
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.createBetTopMargin.constant = self.createBetTopMarginAnimateByY
            self.view.layoutIfNeeded()
            
            }, completion: { (finished) -> Void in
                
        })
        
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
