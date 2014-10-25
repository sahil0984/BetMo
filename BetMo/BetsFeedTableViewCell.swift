//
//  BetsFeedTableViewCell.swift
//  BetMo
//
//  Created by Sahil Arora on 10/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class BetsFeedTableViewCell: UITableViewCell {

    @IBOutlet weak var customBetCellView: CustomCellNib!
    
    var bet: Bet = Bet() {
        willSet(currBet) {
            customBetCellView.bet = currBet
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
