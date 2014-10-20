//
//  CreateBetView.swift
//  BetMo
//
//  Created by Sahil Arora on 10/20/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class CreateBetView: UIView {
    
    @IBOutlet var descriptionContentView: UIView!
    @IBOutlet var amountContentView: UIView!
    
    
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
        var nib = UINib(nibName: "CreateBetView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        
        setupCardView(descriptionContentView)
        setupCardView(amountContentView)
        
        addSubview(descriptionContentView)
        addSubview(amountContentView)
        
        descriptionContentView.hidden = false
        amountContentView.hidden = true
    }
    
    func setupCardView(cardView: UIView) {
        cardView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        cardView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        cardView.center = CGPointMake(frame.width/2, frame.height/2)
    }
    
}



