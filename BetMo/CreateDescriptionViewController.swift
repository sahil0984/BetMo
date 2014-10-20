//
//  CreateDescriptionViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/20/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol CreateDescriptionViewControllerDelegate {
    func addedDescToBet(addedDescToBet : Bet) -> Void
}

class CreateDescriptionViewController: UIViewController, CreateAmountViewControllerDelegate {

    @IBOutlet weak var betDescriptionTextView: UITextView!
    
    var newBet = Bet()
    
    var delegate: CreateDescriptionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addedAmountToBet(addedAmountToBet: Bet) {
        newBet = addedAmountToBet
        newBet.setDescription(betDescriptionTextView.text)
        
        self.dismissViewControllerAnimated(false) { () -> Void in
            println("")
            self.delegate?.addedDescToBet(self.newBet)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var createAmountViewController = segue.destinationViewController as CreateAmountViewController
        
        createAmountViewController.delegate = self
    }

}
