//
//  NewBetViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class NewBetViewController: UIViewController, NewBetDescViewControllerDelegate {

    
    @IBOutlet weak var contentView: UIView!
    
    var newBetDescViewController: NewBetDescViewController!
    var newBetAmountViewController: NewBetAmountViewController!
    var newBetOpponentViewController: FriendsListViewController!
    
    var newBet: Bet = Bet()
    
    
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
        
        newBetOpponentViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendsListViewController") as? FriendsListViewController
        
        
        newBetDescViewController.delegate = self
        
        
        activeViewController = newBetDescViewController

    }
    
    
    
    @IBAction func onBackButton(sender: AnyObject) {
        
        if activeViewController == newBetDescViewController {
             self.dismissViewControllerAnimated(true, completion: nil)
        } else if activeViewController == newBetAmountViewController {
            activeViewController = newBetDescViewController
        } else if activeViewController == newBetOpponentViewController {
            activeViewController == newBetAmountViewController
        }
    }
    
    
    func newBetDescSubmitted(betDesc: String) {
        newBet.setDescription(betDesc)
        activeViewController = newBetAmountViewController
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
