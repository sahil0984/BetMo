//
//  ConfirmNewBetViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/20/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class ConfirmNewBetViewController: UIViewController {

    
    @IBOutlet weak var opponentNameLabel: UILabel!
    @IBOutlet weak var betAmountLabel: UILabel!
    @IBOutlet weak var betDescriptionLabel: UILabel!
    
    var newBet = Bet()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let opponent = newBet.getOppenent() {
            opponentNameLabel.text = opponent.getName()
        } else {
            opponentNameLabel.text = "Open bet.."
        }
        
        betAmountLabel.text = "$\(newBet.getAmount())"
        betDescriptionLabel.text = newBet.getDescription()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
