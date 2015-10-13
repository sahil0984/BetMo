//
//  FriendTableViewCell.swift
//  BetMo
//
//  Created by Sahil Arora on 10/10/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var friend: User? {
        willSet {
        }
        didSet {
            nameLabel.text = friend?.getName()
            
            let urlRequest = NSURLRequest(URL: NSURL(string: (friend!.getProfileImageUrl())!)!)
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
