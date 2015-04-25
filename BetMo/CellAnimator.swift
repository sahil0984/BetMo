//
//  FlipInCellAnimator.swift
//  BetMo
//
//  Created by Sahil Arora on 10/15/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class CellAnimator {
    
    class func animateCellAppear(cell:UITableViewCell) {
    
        let view = cell.contentView
        let rotationDegrees: CGFloat = -15.0
        let rotationRadians: CGFloat = rotationDegrees * (CGFloat(M_PI)/180.0)
        let offset = CGPointMake(-20, -20)
        var startTransform = CATransform3DIdentity // 2
        startTransform = CATransform3DRotate(CATransform3DIdentity,
            rotationRadians, 0.0, 0.0, 1.0) // 3
        startTransform = CATransform3DTranslate(startTransform, offset.x, offset.y, 0.0) // 4
        
        // 5
        view.layer.transform = startTransform
        view.layer.opacity = 0.8
        
        // 6
        UIView.animateWithDuration(0.4) {
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1
        }
    }
    
//    class func animate2(cell:UITableViewCell) {
//        let view = cell.contentView
//        
//        var startTransform = CATransform3DIdentity
//        view.layer.transform = startTransform
//        
//        UIView.animateWithDuration(2.0, animations: { () -> Void in
//            //animate actions
//            var passOneTransform = CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0.1)
//            view.layer.transform = passOneTransform
//            
//        }) { (finished) -> Void in
//            //Post animate
//            
//        }
//    }
    
    class func animate3(cell:UITableViewCell) {
        let view = cell.contentView
        
        
        var startTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
        startTransform = CGAffineTransformTranslate(startTransform, 0.0, 0.0)
        view.layer.setAffineTransform(startTransform)
        
        UIView.animateWithDuration(2.0, animations: { () -> Void in
            //animate actions
            var passOneTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, -0.1)
            passOneTransform = CGAffineTransformTranslate(passOneTransform, 0.0, 0.0)
            view.layer.setAffineTransform(passOneTransform)
            
            }) { (finished) -> Void in
                //Post animate
//                UIView.animateWithDuration(2.0, animations: { () -> Void in
//                    var passTwoTransform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
//                    view.layer.setAffineTransform(passTwoTransform)
//                })
                
        }
    }
    
    class func animateCellFlip(cell:UITableViewCell) {
        let view = cell.contentView as! BetCell
        
        UIView.animateWithDuration(2.0, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
            //Nothing
            cell.contentView.insertSubview(view.profileImageView, aboveSubview: view.headlineLabel)
        }) { (finished) -> Void in
            //Nothing
        }
    }
    
    
}