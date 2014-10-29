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
    
    var screenWidth: CGFloat? {
        willSet {

        }
        didSet {
            //friendImageView.bounds.width = screenWidth/3
            //friendImageView.bounds.height = screenWidth/3
            //self.frame.width = screenWidth/3
            //self.frame.height = screenWidth/3

            //self.frame = CGRectMake(0, 0, screenWidth!/3, screenWidth!/3);
            self.frame.size.height = screenWidth!/3
            self.frame.size.width = screenWidth!/3

        }
    }
    
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
