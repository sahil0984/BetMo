//
//  BetDetailViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class BetDetailViewController: UIViewController {

    @IBOutlet weak var ownerUserNameLabel: UILabel!
    @IBOutlet weak var ownerUserImageView: UIImageView!
    
    @IBOutlet weak var opponentUserNameLabel: UILabel!
    @IBOutlet weak var opponentUserImageView: UIImageView!
    
    @IBOutlet weak var betDescriptionLabel: UILabel!
    @IBOutlet weak var betAmountLabel: UILabel!
    
    var currBet: Bet = Bet()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ownerUserNameLabel.text = currBet.getOwner().getName()
        opponentUserNameLabel.text = currBet.getOppenent()?.getName() ?? ""
        
        var urlRequest = NSURLRequest(URL: NSURL(string: (currBet.getOwner().getProfileImageUrl())!))
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
            if connectionError == nil && data != nil {
                self.ownerUserImageView.image = UIImage(data: data!)
            }
        }
        
        urlRequest = NSURLRequest(URL: NSURL(string: (currBet.getOppenent()?.getProfileImageUrl())!))
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
            if connectionError == nil && data != nil {
                self.opponentUserImageView.image = UIImage(data: data!)
            }
        }
        
        betDescriptionLabel.text = currBet.getDescription()
        betAmountLabel.text = currBet.getAmount()
        
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
