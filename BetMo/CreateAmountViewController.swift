//
//  CreateAmountViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/20/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol CreateAmountViewControllerDelegate {
    func addedAmountToBet(addedAmountToBet : Bet) -> Void
}

class CreateAmountViewController: UIViewController {

    @IBOutlet weak var betAmountTextField: UITextField!
    
    var newBet = Bet()
    
    var delegate: CreateAmountViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func friendSelected(selectedFriend: User) {
        var currentUser = PFUser.currentUser() as User
        newBet.setOwner(currentUser)
        newBet.setOpponent(selectedFriend)
        newBet.setIsAccepted(false)
        
        self.dismissViewControllerAnimated(false) { () -> Void in
            println("")
            self.delegate?.addedAmountToBet(self.newBet)
        }
        
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var friendsListViewController = segue.destinationViewController as FriendsListViewController
        
        newBet.setAmount(betAmountTextField.text)
        friendsListViewController.newBet = newBet
        
        //friendsListViewController.delegate = self
    }


}
