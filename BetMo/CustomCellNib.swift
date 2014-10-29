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
    func betRejected(customCellNib: CustomCellNib, rejectedBet : Bet) -> Void
    func betCancelled(customCellNib: CustomCellNib, cancelledBet : Bet) -> Void
    func winnerChosen(customCellNib: CustomCellNib, bet: Bet)
}

class CustomCellNib: UIView {
    @IBOutlet var mainContentView: UIView!
    @IBOutlet var acceptContentView: UIView!
    @IBOutlet var winnerContentView: UIView!
    
    @IBOutlet weak var acceptedStampLabel: UILabel!
    @IBOutlet weak var rejectedStampLabel: UILabel!

    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    @IBOutlet weak var noMoreBetsLabel: UILabel!
    
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var opponentImageView: UIImageView!
    
    @IBOutlet weak var betAmount: UILabel!
    @IBOutlet weak var betDescription: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var actionButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var subscriberCountLabel: UILabel!
    @IBOutlet weak var firstArrowImageView: UIImageView!
    @IBOutlet weak var secondArrowImageView: UIImageView!

    @IBOutlet weak var ownerStampImage: UIImageView!
    @IBOutlet weak var opponentStampImage: UIImageView!
    var winnerImage = UIImage(named: "WINNER_STAMP")
    var loserImage = UIImage(named: "LOSER_STAMP")

    @IBOutlet weak var chooseWinnerLabel: UILabel!
    @IBOutlet weak var chooseWinnerButton: UIView!
    @IBOutlet weak var noMoreBetsView: UIView!
    @IBOutlet weak var acceptContainer: UIView!
    @IBOutlet weak var declineButton: UIView!
    @IBOutlet weak var acceptButton: UIView!

    @IBOutlet weak var declineLabel: UILabel!
    @IBOutlet weak var acceptLabel: UILabel!

    @IBOutlet weak var cancelBetContainer: UIView!
    @IBOutlet weak var cancelLabel: UILabel!
    var delegate: CustomCellNibDelegate?
    var cancelAlert = UIAlertView()

    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!

    var arrowOriginalY: CGFloat!
    var rowIndex: Int!
    var stampRotation: CGFloat!

    var isDiscoverView: Bool = false

    var isRequest: Bool = false {
        willSet(value) {
            if value {
//                actionButton.hidden = false
//                self.actionButtonBottomConstraint.constant = 10
            }
        }
    }
    
    var bet: Bet = Bet() {
        willSet(currBet) {
            fillMainCard(currBet)
            fillWinnerCard(currBet)
            swapViewWithMainView()
        }
        didSet {
            
        }
    }
    
    var noContentView: Bool = false {
        willSet(newValue) {
            if newValue {
                noMoreBetsView.hidden = false
            }
        }
    }
    func fillMainCard(currBet: Bet) {
        hideAllButtons()
        // hide masks by default (they might have been un-hidden by the bet that previously used this cell)
        // @TODO(samoli) this might not be necessary any longer since I added "hidden" to the storyboard
        setupStamps()
        ownerStampImage.hidden = true
        opponentStampImage.hidden = true

        descriptionBottomConstraint.constant = 20

        ownerNameLabel.text = currBet.getOwner().getName()
        BetMoGetImage.sharedInstance.getUserImage(currBet.getOwner().getProfileImageUrl(), completion: { (userImage, error) -> () in
            if error == nil {
                self.ownerImageView.image = userImage
                // set mask if needed
                if currBet.isClosedBet() {
                    if currBet.isOwnerWinner() {
                        self.ownerStampImage.image = self.winnerImage
                    } else {
                        self.ownerStampImage.image = self.loserImage
                    }
                    // unhide mask
                    self.ownerStampImage.hidden = false
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
                            self.opponentStampImage.image = self.winnerImage
                        } else {
                            self.opponentStampImage.image = self.loserImage
                        }
                        // unhide mask
                        self.opponentStampImage.hidden = false
                    }
                } else {
                    println(error)
                }
            })
        } else {
            opponentNameLabel.text = "No Opponent"
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

        var currUser = PFUser.currentUser() as User
        var betOwner = currBet.getOwner()
        var betOpponent = currBet.getOppenent()
        
        if currBet.isOpenBet() && !currBet.isUserOwner() {
            //Open bets - Accept button
//            actionButton.setTitle("Accept Bet", forState: UIControlState.Normal)
            showAcceptDecline()
        } else if currBet.isPendingAcceptBet() && currBet.isUserOpponent() {
            //Pending accept bets - Accept button
//            actionButton.setTitle("Accept Bet", forState: UIControlState.Normal)
            showAcceptDecline()
        } else if (currBet.isPendingAcceptBet() || betOpponent == nil) && currBet.isUserOwner() {
//            actionButton.setTitle("Cancel Bet", forState: UIControlState.Normal)
            showCancel()
        } else if currBet.isUndecidedBet() && (currBet.isUserOwner() || currBet.isUserOpponent()) {
            //Undecided bets - Select Winner button
            showChooseWinner()
//            actionButton.hidden = true
//            actionButton.setTitle("Pick Winner", forState: UIControlState.Normal)
//            self.actionButtonBottomConstraint.constant = 10
        } else if currBet.isClosedBet() {
            //Closed bet - Select Winner button
//            actionButton.setTitle("Closed Bet", forState: UIControlState.Normal)
            if isRequest {
//                descriptionBottomConstraint.constant = 0
            }
//            actionButton.hidden = true
        } else {
            //CurrUser is not a party to this bet
//            actionButton.setTitle("Error", forState: UIControlState.Normal)
//            actionButton.hidden = true
        }
        
        //Show subscribe button
        updateWatcherViews(currBet.isUserWatcher(), watcherCount: currBet.getWatcherListCount())
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
        setupStamps()
        setupButtons()

        var rotation = -1 * CGFloat(Double(20) * M_PI / 180)
        ownerStampImage.transform = CGAffineTransformMakeRotation(rotation)
        opponentStampImage.transform = CGAffineTransformMakeRotation(rotation)
    }
    
    func setupCardView(cardView: UIView) {
        cardView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        cardView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        cardView.center = CGPointMake(frame.width/2, frame.height/2)
        cardView.layer.cornerRadius = 15
        cardView.layer.masksToBounds = true

        // Set 1 px border
        layer.borderColor = UIColor(red: 182/255.0, green: 182/255.0, blue: 182/255.0, alpha: 1).CGColor
        layer.borderWidth = 1.0

        // Shadow stuff
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        // Opacity of the shadow
        layer.shadowOpacity = 0.2
        // higer this value the blurrier the shadoow
        layer.shadowRadius = 1.5
        layer.cornerRadius = 15

        ownerNameLabel.font = UIFont(name: "OpenSans-Semibold", size: 13)
        opponentNameLabel.font = UIFont(name: "OpenSans-Semibold", size: 13)
        betAmount.font = UIFont(name: "OpenSans-Light", size: 52)
        betDescription.font = UIFont(name: "OpenSans-Regular", size: 16)
        noMoreBetsLabel.font = UIFont(name: "OpenSans-Semibold", size: 20)
        noMoreBetsLabel.textColor = UIColor.darkGrayColor()
    }
    


    @IBAction func onChooseWinnerTap(sender: UITapGestureRecognizer) {
        var currBet = bet
        var currUser = PFUser.currentUser() as User
        var betOwner = currBet.getOwner()
        var betOpponent = currBet.getOppenent()
        swapViewWithWinnerView()
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
        } else if actionButton.titleLabel?.text == "Cancel Bet" {
            //Undecided bets - Select Winner button
            println("Cancel bet pressed")
            delegate?.betCancelled(self, cancelledBet: currBet)
            currBet.cancel()
        } else {
            //Either this is a closed bet or currUser is not a party to this bet
            println("Cant press this button")
            swapViewWithMainView()
        }
    }
    


    @IBAction func onSubscribeButton(sender: AnyObject) {
        //Handle bet subscription
        
        if bet.isClosedBet() == false && bet.isUserOpponent() == false && bet.isUserOwner() == false  {
            if bet.isUserWatcher() {
                updateWatcherViews(false, watcherCount: bet.getWatcherListCount()-1)
                bet.unWatch()
            } else {
                updateWatcherViews(true, watcherCount: bet.getWatcherListCount()+1)
                bet.watch()
            }
        }

        
    }
    
    func updateWatcherViews(isWatcher: Bool, watcherCount: Int) {
        subscriberCountLabel.text = "\(watcherCount)"
        if isWatcher { //if already subscribed
            subscribeButton.setImage(UIImage(named: "watchOn"), forState: UIControlState.Normal)
        } else {
            subscribeButton.setImage(UIImage(named: "watchOff"), forState: UIControlState.Normal)
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
    
    @IBAction func onCancel(sender: UITapGestureRecognizer) {
        cancelAlert.delegate = self
        cancelAlert.message = "Do you want to cancel this bet request?"

        cancelAlert.addButtonWithTitle("No")
        cancelAlert.addButtonWithTitle("Yes")
        
        cancelAlert.title = "Pending Request"
        
        cancelAlert.show()
    }

    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1 {
            // cancel bet
            delegate?.betCancelled(self, cancelledBet: bet)
            bet.cancel()
        } else {
            // no action
        }
    }

    @IBAction func acceptTap(sender: UITapGestureRecognizer) {
        var currUser = PFUser.currentUser() as User
        
        //Create a tmp bet and assign it to bet just to call the property observer.
        var tmpBet = bet
        tmpBet.setIsAccepted(true)
        tmpBet.setOpponent(currUser)
        bet = tmpBet
        
        bet.accept()
        
        delegate?.betAccepted(bet)
    }
    
    @IBAction func declineTap(sender: UITapGestureRecognizer) {
        bet.reject()
        
        delegate?.betRejected(self, rejectedBet: bet)
    }
    
    
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
        
        delegate?.betRejected(self, rejectedBet: bet)
    }
    @IBAction func onCancelButton(sender: AnyObject) {
        swapViewWithMainView()
    }
    
    //Winner card button logic:
    //--------------------------
    @IBAction func onOwnerImageTap(sender: UITapGestureRecognizer) {
        MBProgressHUD.showHUDAddedTo(self.mainContentView, animated: true)
        var currUser = PFUser.currentUser() as User
        if currUser.getFbId() == bet.getOwner().getFbId() {
            bet.wonWithCompletion({ (bet, error) -> () in
                if error == nil {
                    self.delegate?.winnerChosen(self, bet: bet!)
                    MBProgressHUD.hideHUDForView(self.mainContentView, animated: true)
                    self.bet = bet!
                }
            })
        } else if currUser.getFbId() == bet.getOppenent()?.getFbId() {
            bet.lostWithCompletion({ (bet, error) -> () in
                if error == nil {
                    self.delegate?.winnerChosen(self, bet: bet!)
                    MBProgressHUD.hideHUDForView(self.mainContentView, animated: true)
                    self.bet = bet!
                }
            })
        }
    }
    @IBAction func onOpponentImageTap(sender: UITapGestureRecognizer) {
        MBProgressHUD.showHUDAddedTo(self.mainContentView, animated: true)
        var currUser = PFUser.currentUser() as User
        if currUser.getFbId() == bet.getOppenent()?.getFbId() {
            bet.wonWithCompletion({ (bet, error) -> () in
                if error == nil {
                    self.delegate?.winnerChosen(self, bet: bet!)
                    MBProgressHUD.hideHUDForView(self.mainContentView, animated: true)
                    self.bet = bet!
                }
            })
        } else if currUser.getFbId() == bet.getOwner().getFbId() {
            bet.lostWithCompletion({ (bet, error) -> () in
                if error == nil {
                    self.delegate?.winnerChosen(self, bet: bet!)
                    MBProgressHUD.hideHUDForView(self.mainContentView, animated: true)
                    self.bet = bet!
                }
            })
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

    func setupStamps() {
        acceptedStampLabel.font = UIFont(name: "OpenSans-Semibold", size: 40)
        rejectedStampLabel.font = UIFont(name: "OpenSans-Semibold", size: 40)
        stampRotation = CGFloat(Double(10) * M_PI / 180)
        acceptedStampLabel.transform = CGAffineTransformMakeRotation(-1*stampRotation)
        acceptedStampLabel.transform = CGAffineTransformScale(acceptedStampLabel.transform, 2, 2)
        rejectedStampLabel.transform = CGAffineTransformMakeRotation(-1*stampRotation)
        rejectedStampLabel.transform = CGAffineTransformScale(rejectedStampLabel.transform, 2, 2)
    }

    func showChooseWinner() {
        if !isDiscoverView {
            descriptionBottomConstraint.constant = 70
            chooseWinnerButton.hidden = false
        }
    }

    func showAcceptDecline() {
        if !isDiscoverView {
            descriptionBottomConstraint.constant = 70
            acceptContainer.hidden = false
        }
    }

    func showCancel() {
        descriptionBottomConstraint.constant = 70
        cancelBetContainer.hidden = false
    }

    func setupButtons() {
        var blueColor = UIColor(red: 21/255.0, green: 91/255.0, blue: 151/255.0, alpha: 1)
        var grayColor = UIColor(red: 208/255.0, green: 208/255.0, blue: 208/255.0, alpha: 1)
        var buttonFont = UIFont(name: "OpenSans-Semibold", size: 14)
        
        cancelBetContainer.backgroundColor = grayColor
        cancelBetContainer.layer.cornerRadius = 5
        cancelLabel.font = buttonFont
        cancelLabel.textColor = UIColor.darkGrayColor()
        
        acceptButton.backgroundColor = blueColor
        acceptButton.layer.cornerRadius = 5
        acceptLabel.font = buttonFont
        declineButton.backgroundColor = grayColor
        declineButton.layer.cornerRadius = 5
        declineLabel.font = buttonFont
        declineLabel.textColor = UIColor.darkGrayColor()
        
        chooseWinnerButton.backgroundColor = blueColor
        chooseWinnerButton.layer.cornerRadius = 5
        chooseWinnerLabel.font = buttonFont
    }

    func hideAllButtons() {
        chooseWinnerButton.hidden = true
        acceptContainer.hidden = true
        cancelBetContainer.hidden = true
    }
}
