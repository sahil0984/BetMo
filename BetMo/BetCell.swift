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
            var profileImageUrl = owner.getProfileImageUrl()!
            var opponentName = ""
            if  opponent != nil {
                opponentName = opponent!.getName()
            }
            var winnerName = ""
            if winner != nil {
                winnerName = winner!.getName()
            }
            var amount = "$" + betInfo.getAmount()!
            var betHeadline: NSString!
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
                if winner?.getFbId()! == opponent?.getFbId()! {
                    betHeadline = "\(opponentName) won \(amount) from \(ownerName) "
                } else {
                    betHeadline = "\(ownerName) won \(amount) from \(opponentName)"
                }
                // set the winner's profile image
                profileImageUrl = winner!.getProfileImageUrl()!
            } else if opponentName.isEmpty {
                betHeadline = "\(ownerName) \(wantString) to bet \(amount)"
            } else if owner.getFbId() == currentUser.getFbId() {
                if opponentName.isEmpty {
                    // no opponent
                    betHeadline = "\(ownerName) \(wantString) to bet \(amount)"
                } else if betInfo.getIsAccepted() == false {
                    // bet hasn't been accepted
                    betHeadline = "\(ownerName) asked to bet \(amount) against \(opponentName)"
                    profileImageUrl = opponent!.getProfileImageUrl()!
                } else if winnerName.isEmpty {
                    // bet is still ongoing
                    betHeadline = "\(ownerName) bet \(amount) against \(opponentName)"
                    profileImageUrl = opponent!.getProfileImageUrl()!
                } else {
                    // bet is complete
                    if winnerName == owner.getName() {
                       betHeadline = "\(ownerName) won \(amount) from \(opponentName)"
                    } else {
                        betHeadline = "\(opponentName) won \(amount) from \(ownerName)"
                    }
                    profileImageUrl = opponent!.getProfileImageUrl()!
                }
            } else if !opponentName.isEmpty {
                // Someone bet me
                if opponent?.getFbId() == currentUser.getFbId() {
                    if betInfo.getIsAccepted() == false {
                        // I haven't accepted and no one has won yet
                        betHeadline = "\(ownerName) asked to bet \(amount) against \(opponentName)"
                    } else if winnerName.isEmpty {
                        // bet was accepted by me but no one has won
                        betHeadline = "\(ownerName) bet \(amount) against \(opponentName)"
                    } else if !winnerName.isEmpty {
                        // bet is complete
                        if winnerName == owner.getName() {
                            betHeadline = "\(opponentName) won \(amount) from \(ownerName)"
                        } else {
                            betHeadline = "\(ownerName) won \(amount) from \(opponentName)"
                        }
                    }
                    profileImageUrl = owner.getProfileImageUrl()!
                }
            }

            // Create bold attribute
            var boldFont = UIFont.boldSystemFontOfSize(14.0)
            let boldAttribute = [ NSFontAttributeName: boldFont ] as NSDictionary

            // Apply it to the owner name if it appears in the headline
            var attributedString = NSMutableAttributedString(string: betHeadline)
            var rangeOfOwnerName = betHeadline.rangeOfString(ownerName as NSString)

            if rangeOfOwnerName.location != NSNotFound {
                attributedString.setAttributes(boldAttribute, range: rangeOfOwnerName)
            }

            // Apply it to the opponent name if it appears in the headline
            if opponent != nil {
                var rangeOfOpponentName = betHeadline.rangeOfString(opponentName as NSString)
                if rangeOfOpponentName.location != NSNotFound {
                    attributedString.setAttributes(boldAttribute, range: rangeOfOpponentName)
                }
            }

            // Apply it to the winner name if it appears in the headline
            if winner != nil {
                var rangeOfWinnerName = betHeadline.rangeOfString(winnerName as NSString)
                if rangeOfWinnerName.location != NSNotFound {
                    attributedString.setAttributes(boldAttribute, range: rangeOfWinnerName)
                }
            }

            // Apply it to the $Amount
            var rangeOfAmount = betHeadline.rangeOfString(amount as NSString)
            if rangeOfAmount.location != NSNotFound {
                attributedString.setAttributes(boldAttribute, range: rangeOfAmount)
            }

            headlineLabel.attributedText = attributedString
            descriptionLabel.text = betInfo.getDescription()
            timestampLabel.text = betInfo.getCreatedAt()

            var urlRequest = NSURLRequest(URL: NSURL(string: profileImageUrl))
            self.profileImageView.alpha = 0
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
                if connectionError == nil && data != nil {
                    self.profileImageView.image = UIImage(data: data!)
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.profileImageView.alpha = 1.0
                    })
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
