//
//  BetDetailViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol BetDetailViewControllerDelegate {
    func acceptedBet(betAccepted : Bet) -> Void
}

class BetDetailViewController: UIViewController, UIAlertViewDelegate {

    @IBOutlet weak var ownerUserNameLabel: UILabel!
    @IBOutlet weak var ownerUserImageView: UIImageView!
    
    @IBOutlet weak var opponentUserNameLabel: UILabel!
    @IBOutlet weak var opponentUserImageView: UIImageView!
    
    @IBOutlet weak var betDescriptionLabel: UILabel!
    @IBOutlet weak var betAmountLabel: UILabel!
    
    @IBOutlet weak var betDecisionSegmentControl: UISegmentedControl!

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var requestButton: UIButton!

    var currBet: Bet = Bet()
    
    var delegate: BetDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.ownerUserNameLabel.text = currBet.getOwner().getName()
        
        var urlRequest = NSURLRequest(URL: NSURL(string: (currBet.getOwner().getProfileImageUrl())!))
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
            if connectionError == nil && data != nil {
                self.ownerUserImageView.image = UIImage(data: data!)
            }
        }
        
        
        if (currBet.getOppenent()? != nil) {
            opponentUserNameLabel.text = currBet.getOppenent()?.getName()
            
            urlRequest = NSURLRequest(URL: NSURL(string: (currBet.getOppenent()?.getProfileImageUrl())!))
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
                if connectionError == nil && data != nil {
                    self.opponentUserImageView.image = UIImage(data: data!)
                }
            }
        } else {

            opponentUserNameLabel.text = "No opponent!"
        }
        
        betDescriptionLabel.text = currBet.getDescription()
        betAmountLabel.text = currBet.getAmount()
        
        var currentUser = PFUser.currentUser() as User
        
        if currBet.getOwner().getFbId() == currentUser.getFbId() || currBet.getOppenent()? != nil || currBet.getIsAccepted() {
            //acceptButton.setTitle("", forState: UIControlState.Normal)
            acceptButton.hidden = true
        }

        if let winner = currBet.getWinner()? {
            if winner.getFbId() == currBet.getOwner().getFbId() {
                setSegControlOwnerWinner()
            } else {
                setSegControlOpponentWinner()
            }
            
            if winner.getFbId() == currentUser.getFbId() {
                requestButton.hidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onWinnerSelect(sender: AnyObject) {
        var currUser = PFUser.currentUser() as User
        
        if betDecisionSegmentControl.selectedSegmentIndex == 0 {
            setSegControlOwnerWinner()
            if currUser.getFbId() == currBet.getOwner().getFbId() {
                println("hereiam")
                currBet.won()
            } else if currUser.getFbId() == currBet.getOppenent()?.getFbId() {
                currBet.lost()
            }
        } else {
            setSegControlOpponentWinner()
            if currUser.getFbId() == currBet.getOppenent()?.getFbId() {
                currBet.won()
            } else if currUser.getFbId() == currBet.getOwner().getFbId() {
                currBet.lost()
            }
        }
    }
    
    func setSegControlOwnerWinner() {
        betDecisionSegmentControl.selectedSegmentIndex = 0
        betDecisionSegmentControl.setTitle("Won", forSegmentAtIndex: 0)
        betDecisionSegmentControl.setTitle("Lost", forSegmentAtIndex: 1)
    }
    func setSegControlOpponentWinner() {
        betDecisionSegmentControl.selectedSegmentIndex = 1
        betDecisionSegmentControl.setTitle("Won", forSegmentAtIndex: 1)
        betDecisionSegmentControl.setTitle("Lost", forSegmentAtIndex: 0)
    }
    
    
    @IBAction func onAcceptButton(sender: AnyObject) {
        if currBet.getOwner() != PFUser.currentUser() && (currBet.getOppenent()? == nil || !currBet.getIsAccepted()) {
           UIAlertView(title: "Accept Bet", message: "Do you want to accept this bet?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Yes").show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        println("clicked \(buttonIndex)")
        if buttonIndex == 1 {
            currBet.accept()
            acceptButton.hidden = true
            var currUser = PFUser.currentUser() as User
            self.opponentUserNameLabel.text = currUser.getName()
            var urlRequest = NSURLRequest(URL: NSURL(string: (currUser.getProfileImageUrl())!))
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
                if connectionError == nil && data != nil {
                    self.opponentUserImageView.image = UIImage(data: data!)
                }
            }
            delegate?.acceptedBet(currBet)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var paymentNavigationController = segue.destinationViewController as UINavigationController
        var paymentViewController = paymentNavigationController.viewControllers[0] as PaymentViewController
        paymentViewController.bet = currBet
    }
}
