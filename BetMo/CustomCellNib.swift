//
//  CustomCellNib.swift
//  BetMo
//
//  Created by Sahil Arora on 10/15/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class CustomCellNib: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        var nib = UINib(nibName: "CustomCellNib", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        
        contentView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        //contentView.frame = bounds
        addSubview(contentView)
    }
    
//    func animateFlip() {
//        UIView.animateWithDuration(0.5, delay: 0, options: nil, animations: { () -> Void in
//            contentView.transform =
//        }, completion: nil)
//    }

}
