//
//  CardHeaderView.swift
//  BetMo
//
//  Created by Sahil Arora on 4/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

class CardHeaderView: UIView {

    var view: UIView!
    
    var nibName: String = "CardHeaderView"
    
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var opponentImageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    
    override init(frame: CGRect) {
        //Set properties here
        
        super.init(frame:frame)
        
        //Set anything that uses the view or visible bounds
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        //Set properties here

        super.init(coder: aDecoder)
        
        //Setup
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        addSubview(view)
        
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    var bet: Bet = Bet(className: "Bet") {
        willSet(currBet) {
            fillView(currBet)
        }
        didSet {
            
        }
    }
    
    func fillView(currBet: Bet) {
        var ownerR = currBet.getOwner()
        var ownerRnameE = ownerR.getName()
        ownerNameLabel.text = currBet.getOwner().getName()
        BetMoGetImage.sharedInstance.getUserImage(currBet.getOwner().getProfileImageUrl(), completion: { (userImage, error) -> () in
            if error == nil {
                self.ownerImageView.image = userImage
            } else {
                println(error)
            }
        })
        
        //Check if opponent exists
        if let currOpponent = currBet.getOppenent() {
            opponentNameLabel.text = currOpponent.getName()
            BetMoGetImage.sharedInstance.getUserImage(currBet.getOppenent()?.getProfileImageUrl(), completion: { (userImage, error) -> () in
                if error == nil {
                    self.opponentImageView.image = userImage
                } else {
                    println(error)
                }
            })
        } else {
            opponentNameLabel.text = "No Opponent"
            self.opponentImageView.image = UIImage(named: "empty_user")
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
