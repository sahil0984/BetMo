//
//  CustomCellNib.swift
//  BetMo
//
//  Created by Sahil Arora on 10/15/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class CustomCellNib: UIView {

    @IBOutlet var mainContentView: UIView!
    @IBOutlet var acceptContentView: UIView!
    @IBOutlet var winnerContentView: UIView!
    
    
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var opponentImageView: UIImageView!
    
    @IBOutlet weak var betAmount: UILabel!
    @IBOutlet weak var betDescription: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var subscriberCountLabel: UILabel!
    
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
        ownerNameLabel.text = currBet.getOwner().getName()
        BetMoGetImage.sharedInstance.getUserImage(currBet.getOwner().getProfileImageUrl(), completion: { (userImage, error) -> () in
            if error == nil {
                self.ownerImageView.image = userImage
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
        
        if currBet.isOpenBet() {
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
            actionButton.setTitle("Pick Winner", forState: UIControlState.Normal)
            //actionButton.hidden = true
        } else {
            //CurrUser is not a party to this bet
            actionButton.setTitle("Closed Bet", forState: UIControlState.Normal)
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
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true
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
        winnerContentView.hidden = false
    }
    
    //Accept card button logic:
    //--------------------------
    @IBAction func onAcceptButton(sender: AnyObject) {
        bet.accept()
        //somehow call property observer. maybe pass delegate to refresh this table cell??
    }
    @IBAction func onRejectButton(sender: AnyObject) {
        //swapViewWithMainView()
        bet.reject()
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
    
    
}
