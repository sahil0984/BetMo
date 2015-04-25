//
//  NewBetConfirmViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/27/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol NewBetConfirmViewControllerDelegate {
    func newBetConfirmed(newBet: Bet)
    func newBetCancelled(newBet: Bet)
}

class NewBetConfirmViewController: UIViewController {

    @IBOutlet weak var confirmBetContentView: CustomCellNib!
    
    var delegate: NewBetConfirmViewControllerDelegate?
    
    var newBet: Bet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        confirmBetContentView.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        var currentUser = PFUser.currentUser() as! User
        newBet.setOwner(currentUser)
        newBet.setIsAccepted(false)
        
        confirmBetContentView.isDiscoverView = true
        confirmBetContentView.bet = newBet
    }

    
    @IBAction func onAcceptButton(sender: UITapGestureRecognizer) {
        newBet.create()
        delegate?.newBetConfirmed(newBet)
    }
    
    @IBAction func onRejectButton(sender: UITapGestureRecognizer) {
        delegate?.newBetCancelled(newBet)
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
