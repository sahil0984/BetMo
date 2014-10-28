//
//  NewBetViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol NewBetViewControllerDelegate {
    func newBetCreated(newBet: Bet)
}

class NewBetViewController: UIViewController, NewBetDescViewControllerDelegate, NewBetAmountViewControllerDelegate, NewBetOpponentViewControllerDelegate, NewBetConfirmViewControllerDelegate {

    
    @IBOutlet weak var contentView: UIView!
    
    var newBetDescViewController: NewBetDescViewController!
    var newBetAmountViewController: NewBetAmountViewController!
    var newBetOpponentViewController: NewBetOpponentViewController!
    var newBetConfirmViewController: NewBetConfirmViewController!
    
    var newBet: Bet = Bet()
    
    var delegate: NewBetViewControllerDelegate?
    
    // Containers handler
    var activeViewController: UIViewController? {
        didSet(oldViewControllerOrNil) {
            if let oldVC = oldViewControllerOrNil {
                oldVC.willMoveToParentViewController(nil)
                oldVC.view.removeFromSuperview()
                oldVC.removeFromParentViewController()
                self.view.layoutIfNeeded()
            }
            if let newVC = activeViewController {
                self.addChildViewController(newVC)
                newVC.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                newVC.view.frame = self.contentView.bounds
                self.contentView.addSubview(newVC.view)
                newVC.didMoveToParentViewController(self)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var currentUser = PFUser.currentUser() as User
        
        newBetDescViewController = storyboard?.instantiateViewControllerWithIdentifier("NewBetDescViewController") as? NewBetDescViewController
        
        newBetAmountViewController = storyboard?.instantiateViewControllerWithIdentifier("NewBetAmountViewController") as? NewBetAmountViewController
        
        newBetOpponentViewController = storyboard?.instantiateViewControllerWithIdentifier("NewBetOpponentViewController") as? NewBetOpponentViewController
        
        newBetConfirmViewController = storyboard?.instantiateViewControllerWithIdentifier("NewBetConfirmViewController") as? NewBetConfirmViewController
        
        newBetDescViewController.delegate = self
        newBetAmountViewController.delegate = self
        newBetOpponentViewController.delegate = self
        newBetConfirmViewController.delegate = self
        
        activeViewController = newBetDescViewController

    }
    
    
    
    @IBAction func onBackButton(sender: AnyObject) {
        
        if activeViewController == newBetDescViewController {
             self.dismissViewControllerAnimated(true, completion: nil)
        } else if activeViewController == newBetAmountViewController {
            activeViewController = newBetDescViewController
        } else if activeViewController == newBetOpponentViewController {
            activeViewController = newBetAmountViewController
        } else if activeViewController == newBetConfirmViewController {
            activeViewController = newBetOpponentViewController
        }
    }
    
    
    func newBetDescSubmitted(betDesc: String) {
        newBet.setDescription(betDesc)
        activeViewController = newBetAmountViewController
    }
    
    func newBetAmountSubmitted(betAmount: String) {
        newBet.setAmount(betAmount)
        activeViewController = newBetOpponentViewController
    }
    
    func newOpponentSubmitted(betOpponent: User) {
        if betOpponent.getName() != "Open Bet" {
            newBet.setOpponent(betOpponent)
        }
        newBetConfirmViewController.newBet = self.newBet
        activeViewController = newBetConfirmViewController
    }
    
    func newBetConfirmed(newBet: Bet) {
        delegate?.newBetCreated(newBet)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func newBetCancelled(newBet: Bet) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
