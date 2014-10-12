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
            var ownerName = owner.getName()
            var winner = betInfo.getWinner()
            var opponent = betInfo.getOppenent()
            var currentUser = PFUser.currentUser() as User
            
            var opponentName = ""
            if  opponent != nil {
                opponentName = opponent!.getName()
            }
            var winnerName = ""
            if winner != nil {
        
                winnerName = winner!.getName()
            }
            var amount = betInfo.getAmount()!
            var betHeadline: String!
            var wantString = "wants"
            if opponentName == currentUser.getName() {
                opponentName = "You"
                wantString = "want"
            } else if ownerName == currentUser.getName() {
                ownerName = "You"
                wantString = "want"
            }
            // Set the appropriate headline
            if !opponentName.isEmpty && !winnerName.isEmpty {
                if winnerName == opponentName {
                    betHeadline = "\(winnerName) won $\(amount) from \(ownerName) "
                } else {
                    betHeadline = "\(winnerName) won $\(amount) from \(opponentName)"
                }
            } else if opponentName.isEmpty {
                betHeadline = "\(ownerName) \(wantString) to bet $\(amount)"
            } else if owner.getFbId() == currentUser.getFbId() {
                if opponentName.isEmpty {
                    // no opponent
                    betHeadline = "\(ownerName) \(wantString) to bet $\(amount)"
                } else if betInfo.getIsAccepted() == false {
                    // bet hasn't been accepted
                    betHeadline = "\(ownerName) asked to bet $\(amount) against \(opponentName)"
                } else if winnerName.isEmpty {
                    // bet is still ongoing
                    betHeadline = "\(ownerName) bet $\(amount) against \(opponentName)"
                } else {
                    // bet is complete
                    if winnerName == owner.getName() {
                       betHeadline = "\(ownerName) won $\(amount) from \(opponentName)"
                    } else {
                        betHeadline = "\(opponentName) won $\(amount) from \(ownerName)"
                    }
                }
            } else if !opponentName.isEmpty {
                // Someone bet me
                if opponent?.getFbId() == currentUser.getFbId() {
                    if betInfo.getIsAccepted() == false {
                        // I haven't accepted and no one has won yet
                        betHeadline = "\(ownerName) asked to bet $\(amount) against \(opponentName)"
                    } else if winnerName.isEmpty {
                        // bet was accepted by me but no one has won
                        betHeadline = "\(ownerName) bet $\(amount) against \(opponentName)"
                    } else if !winnerName.isEmpty {
                        // bet is complete
                        if winnerName == owner.getName() {
                            betHeadline = "\(opponentName) won $\(amount) from \(ownerName)"
                        } else {
                            betHeadline = "\(ownerName) won $\(amount) from \(opponentName)"
                        }
                    }
                }
            }
            
            headlineLabel.text = betHeadline
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
