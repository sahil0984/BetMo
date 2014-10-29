//
//  FriendCollectionViewCell.swift
//  BetMo
//
//  Created by Sahil Arora on 10/27/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    
    @IBOutlet weak var cellSelectOverlayView: UIView!
    
    var friend: User? {
        willSet {
            
        }
        didSet {
            cellSelectOverlayView.hidden = true
            friendNameLabel.text = friend?.getName()
            BetMoGetImage.sharedInstance.getUserImage(friend?.getProfileImageUrl(), completion: { (userImage, error) -> () in
                if error == nil {
                    self.friendImageView.image = userImage
                } else {
                    println(error)
                }
            })
            

        }
    }
    
}
