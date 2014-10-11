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
            var opponent = betInfo.getOppenent()!
            var ownerName = owner.getName()
            headlineLabel.text = ownerName
            descriptionLabel.text = betInfo.getDescription()
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
