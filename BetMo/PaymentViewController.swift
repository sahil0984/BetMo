//
//  PaymentViewController.swift
//  BetMo
//
//  Created by Sahil Amoli on 10/12/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var payOrRequestSegmnetedControl: UISegmentedControl!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var requestToTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var sendRequestButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    var bet: Bet! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if bet != nil {
            amountTextField.text = bet.getAmount()
            let winner = bet.getWinner()
            let opponent = bet.getOppenent()
            let owner = bet.getOwner()
            let currentUser = PFUser.currentUser() as! User
            var requestTo = ""
            if currentUser.getFbId() == winner?.getFbId() {
                if currentUser.getFbId() == owner.getFbId() {
                    requestTo = opponent?.getName() ?? ""
                } else {
                    requestTo = owner.getName()
                }
            } else {
                // We don't support the send money part
            }
            
            requestToTextField.text = requestTo
            descriptionTextField.text = bet.getDescription()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }

    @IBAction func onSendButton(sender: AnyObject) {
        // Add Venmo logic
        print("sent request")
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
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
