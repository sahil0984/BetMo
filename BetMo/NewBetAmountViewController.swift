//
//  NewBetAmountViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol NewBetAmountViewControllerDelegate {
    func newBetAmountSubmitted(betAmount: String)
}

class NewBetAmountViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!

    @IBOutlet weak var finger: UIImageView!
    @IBOutlet weak var arrowsImage: UIImageView!
    @IBOutlet weak var betTextField: UITextField!

    var delegate: NewBetAmountViewControllerDelegate?
    
    var betAmount = 25
    var originalFingerX: CGFloat!
    var initialPanPosition: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrowsImage.hidden = false
        finger.hidden = false

        betTextField.font = UIFont(name: "OpenSans-Light", size: 70)
        nextButton.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 15)
        
        nextButton.layer.cornerRadius = 5
    }
    
    
    override func viewDidAppear(animated: Bool) {
        originalFingerX = finger.frame.origin.x
        animateFinger()
    }

    @IBAction func onNextButton(sender: AnyObject) {
        delegate?.newBetAmountSubmitted("\(betTextField.text)")
    }
    
    @IBAction func onTapGesture(sender: AnyObject) {
        arrowsImage.hidden = true
        finger.hidden = true

        if (betTextField.isFirstResponder()) {
            if betTextField.text == "" {
                betTextField.text = "0"
            }
            betTextField.endEditing(true)
        } else {
            betTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        arrowsImage.hidden = true
        finger.hidden = true

        var point = panGestureRecognizer.locationInView(view)
        var velocity = panGestureRecognizer.velocityInView(view)
        var absVelocityX = abs(velocity.x)
        var absVelocityY = abs(velocity.y)
        var dir: Int
        
        if velocity.x < 0 {
            dir = -1
        } else {
            dir = 1
        }
        
        if sender.state == UIGestureRecognizerState.Began {
            initialPanPosition = point
        } else if sender.state == UIGestureRecognizerState.Changed {
            var tmpBetAmount = betAmount
            
            if absVelocityX > 1 && absVelocityY < 5 {
                
                var distX = abs((initialPanPosition?.x)! - point.x)
                
                if absVelocityX > 20 && distX > 10 {
                    if absVelocityX < 100 {
                        tmpBetAmount += 1 * dir
                    } else if absVelocityX < 200 {
                        tmpBetAmount += 5 * dir
                    } else if absVelocityX < 300 {
                        tmpBetAmount += 10 * dir
                    } else if absVelocityX < 600 {
                        tmpBetAmount += 50 * dir
                    }
                }
                
                if tmpBetAmount >= 0 {
                    betAmount = tmpBetAmount
                } else {
                    betAmount = 0
                }
            }
        
        } else if sender.state == UIGestureRecognizerState.Ended {
            
        }
        
        //println("At position: \(point)")
        //println("At velocity: \(absVelocityX)")
        
        //println("new amount: \(betAmount)")
        betTextField.text = "\(betAmount)"

    }
    
    
    func animateFinger() {
        UIView.animateWithDuration(1, delay: 0, options: nil, animations: { () -> Void in
            self.finger.frame.origin.x += 75
            }) { (Bool) -> Void in
                UIView.animateWithDuration(1, delay: 0, options: nil, animations: { () -> Void in
                    self.finger.frame.origin.x = self.originalFingerX
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(1, delay: 0, options: nil, animations: { () -> Void in
                                self.finger.frame.origin.x -= 75
                            }, completion: { (Bool) -> Void in
                                UIView.animateWithDuration(1, delay: 0, options: nil, animations: { () -> Void in
                                    self.finger.frame.origin.x = self.originalFingerX
                                    }, completion: { (Bool) -> Void in
                                        self.animateFinger()
                                })
                        })
                })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
