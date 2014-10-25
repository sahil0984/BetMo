//
//  CustomCellNib.swift
//  BetMo
//
//  Created by Sahil Arora on 10/15/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol CustomCellNibDelegate {
    func betAccepted(acceptedBet : Bet) -> Void
    func betRejected(rejectedBet : Bet) -> Void
}

class CustomCellNib: UIView {
    @IBOutlet var mainContentView: UIView!
    @IBOutlet var acceptContentView: UIView!
    @IBOutlet var winnerContentView: UIView!
    
    @IBOutlet weak var ownerEmoji: UIImageView!
    @IBOutlet weak var opponentEmoji: UIImageView!
    
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var opponentImageView: UIImageView!
    
    @IBOutlet weak var betAmount: UILabel!
    @IBOutlet weak var betDescription: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var subscriberCountLabel: UILabel!
    @IBOutlet weak var firstArrowImageView: UIImageView!
    @IBOutlet weak var secondArrowImageView: UIImageView!

    var winningColor = UIColor(red: 8/255.0, green: 158/255.0, blue: 0, alpha: 0.6)
    var losingColor = UIColor(red: 1, green: 59/255.0, blue: 48/255.0, alpha: 0.6)

    @IBOutlet weak var ownerMaskView: UIView!
    @IBOutlet weak var opponentMaskView: UIView!
    
    var delegate: CustomCellNibDelegate?

    var arrowOriginalY: CGFloat!

    var bet: Bet = Bet() {
        willSet(currBet) {
            fillMainCard(currBet)
            fillWinnerCard(currBet)
            
            swapViewWithMainView()
        }
        didSet {
            
        }
    }
    
    func fillMainCard(currBet: Bet) {
        // sets up bet emojis
        setEmojisIfNeeded(currBet)

        // hide masks by default (they might have been un-hidden by the bet that previously used this cell)
        // @TODO(samoli) this might not be necessary any longer since I added "hidden" to the storyboard
        ownerMaskView.hidden = true
        opponentMaskView.hidden = true

        ownerNameLabel.text = currBet.getOwner().getName()
        BetMoGetImage.sharedInstance.getUserImage(currBet.getOwner().getProfileImageUrl(), completion: { (userImage, error) -> () in
            if error == nil {
                self.ownerImageView.image = userImage
                // set mask if needed
                if currBet.isClosedBet() {
                    if currBet.isOwnerWinner() {
                        self.ownerMaskView.backgroundColor = self.winningColor
                    } else {
                        self.ownerMaskView.backgroundColor = self.losingColor
                    }
                    // unhide mask
                    self.ownerMaskView.hidden = false
                }
            } else {
                println(error)
            }
        })
        
        //Check if opponent exists
        if let currOpponent = currBet.getOppenent() {
            opponentNameLabel.text = currOpponent.getName()
            BetMoGetImage.sharedInstance.getUserImage(currBet.getOppenent()?.getProfileImageUrl(), completion: { (userImage, error) -> () in
                if error == nil {
                    self.opponentImageView.image = userImage
                    // set mask if needed
                    if currBet.isClosedBet() {
                        if currBet.isOpponentWinner() {
                            self.opponentMaskView.backgroundColor = self.winningColor
                        } else {
                            self.opponentMaskView.backgroundColor = self.losingColor
                        }
                        // unhide mask
                        self.opponentMaskView.hidden = false
                    }
                } else {
                    println(error)
                }
            })
        } else {
            opponentNameLabel.text = "This could be you."
            self.opponentImageView.image = UIImage(named: "empty_user")
        }
        
        if !currBet.getIsAccepted() {
            opponentImageView.alpha = 0.3
        } else {
            opponentImageView.alpha = 1.0
        }
        
        betAmount.text = "$\(currBet.getAmount()!)"
        betDescription.text = currBet.getDescription()
        
        
        //There can be 4 types of bets:
        //Open bets - Accept button
        //Pending accept bets - Accept button
        //Undecided bets - Select Winner button
        //Closed bets - No button
        
        actionButton.hidden = false
        
        var currUser = PFUser.currentUser() as User
        var betOwner = currBet.getOwner()
        var betOpponent = currBet.getOppenent()
        
        if currBet.isOpenBet() && !currBet.isUserOwner() {
            //Open bets - Accept button
            actionButton.setTitle("Accept Bet", forState: UIControlState.Normal)
        } else if currBet.isPendingAcceptBet() && currBet.isUserOpponent() {
            //Pending accept bets - Accept button
            actionButton.setTitle("Accept Bet", forState: UIControlState.Normal)
        } else if currBet.isUndecidedBet() && (currBet.isUserOwner() || currBet.isUserOpponent()) {
            //Undecided bets - Select Winner button
            actionButton.setTitle("Pick Winner", forState: UIControlState.Normal)
        } else if currBet.isClosedBet() && (currBet.isUserOwner() || currBet.isUserOpponent()) {
            //Closed bet - Select Winner button

            actionButton.setTitle("Closed Bet", forState: UIControlState.Normal)
            //actionButton.hidden = true
        } else {
            //CurrUser is not a party to this bet
            actionButton.setTitle("Error", forState: UIControlState.Normal)
            actionButton.hidden = true
        }
        
        //Show subscribe button
        updateWatcherViews(currBet.isUserWatcher(), watcherCount: currBet.getWatcherListCount())
        
//        subscriberCountLabel.text = "(\(currBet.getWatcherListCount()))"
//        if currBet.isUserWatcher() { //if already subscribed
//            subscribeButton.setImage(UIImage(named: "subscribeOn"), forState: UIControlState.Normal)
//        } else {
//            subscribeButton.setImage(UIImage(named: "subscribeOff"), forState: UIControlState.Normal)
//        }
    }
    
    
    @IBOutlet weak var winnerOwnerNameLabel: UILabel!
    @IBOutlet weak var winnerOpponentNameLabel: UILabel!
    
    @IBOutlet weak var winnerOwnerImageView: UIImageView!
    @IBOutlet weak var winnerOpponentImageView: UIImageView!
    
    func fillWinnerCard(currBet: Bet) {
        winnerOwnerNameLabel.text = currBet.getOwner().getName()
        BetMoGetImage.sharedInstance.getUserImage(currBet.getOwner().getProfileImageUrl(), completion: { (userImage, error) -> () in
            if error == nil {
                self.winnerOwnerImageView.image = userImage
            } else {
                println(error)
            }
        })
        
        //Check if opponent exists
        if let currOpponent = currBet.getOppenent() {
            winnerOpponentNameLabel.text = currOpponent.getName()
            BetMoGetImage.sharedInstance.getUserImage(currBet.getOppenent()?.getProfileImageUrl(), completion: { (userImage, error) -> () in
                if error == nil {
                    self.winnerOpponentImageView.image = userImage
                } else {
                    println(error)
                }
            })
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */
    
    //View Init logic:
    //-------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        var nib = UINib(nibName: "CustomCellNib", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        
        setupCardView(mainContentView)
        setupCardView(acceptContentView)
        setupCardView(winnerContentView)
        // For the winner card we need to save the original Y location of the arrow (for animation)
        arrowOriginalY = firstArrowImageView.frame.origin.y
        
        addSubview(acceptContentView)
        addSubview(mainContentView)
        addSubview(winnerContentView)

        mainContentView.hidden = false
        acceptContentView.hidden = true
        winnerContentView.hidden = true
    }
    
    func setupCardView(cardView: UIView) {
        cardView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        cardView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        cardView.center = CGPointMake(frame.width/2, frame.height/2)
        // Had to comment out rounded corners so that shadow works
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true

        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 2
        layer.cornerRadius = 20
    }
    
    
    //Action Button pressed:
    //-------------------------
    @IBAction func onActionButton(sender: AnyObject) {
        var currBet = bet
        var currUser = PFUser.currentUser() as User
        var betOwner = currBet.getOwner()
        var betOpponent = currBet.getOppenent()
        
        if actionButton.titleLabel?.text == "Accept Bet" {
            //Open bets - Accept button
            println("Accepted pressed")
            swapViewWithAcceptView()
        } else if actionButton.titleLabel?.text == "Pick Winner" {
            //Undecided bets - Select Winner button
            println("Pick winner pressed")
            swapViewWithWinnerView()
        } else {
            //Either this is a closed bet or currUser is not a party to this bet
            println("Cant press this button")
            swapViewWithMainView()
        }
    }
    
    @IBAction func onSubscribeButton(sender: AnyObject) {
        //Handle bet subscription
        if bet.isUserWatcher() {
            updateWatcherViews(false, watcherCount: bet.getWatcherListCount()-1)
            bet.unWatch()
        } else {
            updateWatcherViews(true, watcherCount: bet.getWatcherListCount()+1)
            bet.watch()
        }
        
    }
    
    func updateWatcherViews(isWatcher: Bool, watcherCount: Int) {
        subscriberCountLabel.text = "(\(watcherCount))"
        if isWatcher { //if already subscribed
            subscribeButton.setImage(UIImage(named: "subscribeOn"), forState: UIControlState.Normal)
        } else {
            subscribeButton.setImage(UIImage(named: "subscribeOff"), forState: UIControlState.Normal)
        }
    }
    
    //Card swap logic:
    //-----------------
    func swapViewWithMainView() {
        mainContentView.hidden = false
        acceptContentView.hidden = true
        winnerContentView.hidden = true
        
        UIView.animateWithDuration(2.0, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
            //Nothing
            self.insertSubview(self.mainContentView, aboveSubview: self.acceptContentView)
        }) { (finished) -> Void in
            //Nothing
        }
        //self.layoutIfNeeded()

        
    }
    func swapViewWithAcceptView() {
        //mainContentView.removeFromSuperview()
        
        //sendSubviewToBack(mainContentView)
        //addSubview(acceptContentView)
        
        mainContentView.hidden = true
        acceptContentView.hidden = false
        winnerContentView.hidden = true
        
        UIView.animateWithDuration(2.0, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
            //Nothing
            self.insertSubview(self.acceptContentView, aboveSubview: self.mainContentView)
        }) { (finished) -> Void in
            //Nothing
        }
        //self.layoutIfNeeded()

    }
    func swapViewWithWinnerView() {
        mainContentView.hidden = true
        acceptContentView.hidden = true

        // Animate the arrows to pick the winner before showing thes screen
        animateArrows()
        winnerContentView.hidden = false
    }
    
    //Accept card button logic:
    //--------------------------
    @IBAction func onAcceptButton(sender: AnyObject) {
        var currUser = PFUser.currentUser() as User
        
        //Create a tmp bet and assign it to bet just to call the property observer.
        var tmpBet = bet
        tmpBet.setIsAccepted(true)
        tmpBet.setOpponent(currUser)
        bet = tmpBet
        
        bet.accept()
        
        delegate?.betAccepted(bet)
        
    }
    @IBAction func onRejectButton(sender: AnyObject) {
        
        bet.reject()
        
        delegate?.betRejected(bet)
        
    }
    @IBAction func onCancelButton(sender: AnyObject) {
        swapViewWithMainView()
    }
    
    //Winner card button logic:
    //--------------------------
    @IBAction func onOwnerImageTap(sender: UITapGestureRecognizer) {
//        winnerOwnerImageView.image = winnerOwnerImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//        winnerOwnerImageView.tintColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.55)
        
        var currUser = PFUser.currentUser() as User
        if currUser.getFbId() == bet.getOwner().getFbId() {
            bet.won()
        } else if currUser.getFbId() == bet.getOppenent()?.getFbId() {
            bet.lost()
        }
    }
    @IBAction func onOpponentImageTap(sender: UITapGestureRecognizer) {
        
        var currUser = PFUser.currentUser() as User
        if currUser.getFbId() == bet.getOppenent()?.getFbId() {
            bet.won()
        } else if currUser.getFbId() == bet.getOwner().getFbId() {
            bet.lost()
        }
    }

    func setEmojisIfNeeded(bet: Bet) {
        if let winner = bet.getWinner() {
            let owner = bet.getOwner()
            let opponent = bet.getOppenent()!

            if winner.objectId == bet.getOwner().objectId {
                ownerEmoji.image = UIImage(named: "cool-25")
                opponentEmoji.image = UIImage(named: "sad-25")
                ownerEmoji.hidden = false
                opponentEmoji.hidden = false
            } else {
                opponentEmoji.image = UIImage(named: "cool-25")
                ownerEmoji.image = UIImage(named: "sad-25")
                ownerEmoji.hidden = false
                opponentEmoji.hidden = false
            }
        }
    }

    func animateArrows() {
        // The animation may have ended when the view disappeared but the state of the arrow might be the "animated" state -- reset arrow y positions back to their original
        firstArrowImageView.frame.origin.y = arrowOriginalY
        secondArrowImageView.frame.origin.y = arrowOriginalY

        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.Repeat | UIViewAnimationOptions.Autoreverse, animations: { () -> Void in
            self.firstArrowImageView.frame.origin.y -= 10
            self.secondArrowImageView.frame.origin.y -= 10
        }, completion: nil)
    }
}
