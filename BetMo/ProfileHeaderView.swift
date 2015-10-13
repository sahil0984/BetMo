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

    var visualEffectView: UIVisualEffectView!
    var visualEffectViewTopConstraint: NSLayoutConstraint!

    //View Init logic:
    //-------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let nib = UINib(nibName: "ProfileHeaderView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        setupHeaderView(headerView)
        addSubview(headerView)
        
        proflieImageView.layer.cornerRadius = 32
        let currentUser = PFUser.currentUser() as! User
        let bannerUrl = currentUser.getBannerImageUrl()
        BetMoGetImage.sharedInstance.getUserImage(currentUser.getProfileImageUrl(), completion: { (userImage, error) -> () in
            if error == nil {
                self.proflieImageView.image = userImage
            } else {
                print(error)
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

        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = bannerImageView.bounds
        visualEffectView.alpha = 0
        bannerImageView.addSubview(visualEffectView)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectViewTopConstraint = NSLayoutConstraint(item: visualEffectView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: bannerImageView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        bannerImageView.addConstraint(visualEffectViewTopConstraint)
        bannerImageView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: bannerImageView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        bannerImageView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: bannerImageView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        bannerImageView.addConstraint(NSLayoutConstraint(item: visualEffectView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: bannerImageView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
    }

    func setupHeaderView(cardView: UIView) {
        headerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        headerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
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
