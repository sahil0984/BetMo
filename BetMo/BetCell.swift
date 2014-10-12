//
//  BetCell.swift
//  BetMo
//
//  Created by Sahil Amoli on 10/10/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class BetCell: UITableViewCell {

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!

    var bet: Bet! {
        willSet(betInfo) {
            // Setup cell
            var owner = betInfo.getOwner() as User
            var opponent = betInfo.getOppenent()
            var ownerName = owner.getName()
            var winner = betInfo.getWinner()

            var opponentName = ""
            if let opponentObject = opponent {
                opponentName = opponentObject.getName()
            }
            
            var amount = betInfo.getAmount()!
            headlineLabel.text = "\(ownerName) bet \(opponentName) for $\(amount)"
            descriptionLabel.text = betInfo.getDescription()

            var urlRequest = NSURLRequest(URL: NSURL(string: (owner.getProfileImageUrl())!))
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
                if connectionError == nil && data != nil {
                    self.profileImageView.image = UIImage(data: data!)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
