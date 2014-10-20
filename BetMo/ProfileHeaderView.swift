//
//  ProfileHeaderView.swift
//  BetMo
//
//  Created by Sahil Amoli on 10/19/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class ProfileHeaderView: UIView {

    @IBOutlet var headerView: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var proflieImageView: UIImageView!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var lossesLabel: UILabel!

    //View Init logic:
    //-------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        var nib = UINib(nibName: "ProfileHeaderView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        setupHeaderView(headerView)
        addSubview(headerView)
        
        proflieImageView.layer.cornerRadius = 32
        var currentUser = PFUser.currentUser() as User
        var bannerUrl = currentUser.getBannerImageUrl()
        BetMoGetImage.sharedInstance.getUserImage(currentUser.getProfileImageUrl(), completion: { (userImage, error) -> () in
            if error == nil {
                self.proflieImageView.image = userImage
            } else {
                println(error)
            }
        })
        BetMoGetImage.sharedInstance.getUserBannerImage(bannerUrl, completion: { (userBannerImage, error) -> () in
            self.bannerImageView.image = userBannerImage
        })
        BetMoClient.sharedInstance.getTotalLossesForUser(currentUser, completion: { (lossCount, error) -> () in
            self.lossesLabel.text = "\(lossCount!) Losses"
        })
        BetMoClient.sharedInstance.getTotalWinsForUser(currentUser, completion: { (winCount, error) -> () in
            self.winsLabel.text = "\(winCount!) Wins"
        })
    }

    func setupHeaderView(cardView: UIView) {
        headerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        headerView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        headerView.center = CGPointMake(frame.width/2, frame.height/2)
        headerView.layer.masksToBounds = true
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}