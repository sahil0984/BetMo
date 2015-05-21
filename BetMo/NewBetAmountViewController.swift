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

class NewBetAmountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBotConstraint: NSLayoutConstraint!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!

    @IBOutlet weak var finger: UIImageView!
    @IBOutlet weak var arrowsImage: UIImageView!
    @IBOutlet weak var betTextField: UITextField!

    var delegate: NewBetAmountViewControllerDelegate?
    var originalFingerX: CGFloat!
    var initialPanPosition: CGPoint?
    
    var betAmount: Float = 25.0
    var amt = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrowsImage.hidden = false
        finger.hidden = false

        betTextField.delegate = self
        betTextField.font = UIFont(name: "OpenSans-Light", size: 70)
        nextButton.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 15)
        
        nextButton.layer.cornerRadius = 5
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
//        //Pre calculate piece-wise intervals for a polynomial function
//        var C3 = 1000
//        var C2 = 1
//        var C1 = 1
//        var C0 = 0
//        var y = 0
//        for var x=0; x<1000; x=x+20 {
//            var normX = x/1000
//            y = (C3 * normX^3) + (C2 * normX^2) + (C1 * normX^1) + (C0 * normX^0)
//            amt.append(y)
//        }
        
    }

    override func viewDidAppear(animated: Bool) {
        originalFingerX = finger.frame.origin.x
        animateFinger()
    }
    
    func keyboardWillShow(notification: NSNotification!) {
        var userInfo = notification.userInfo!
        
        // Get the keyboard height and width from the notification
        // Size varies depending on OS, language, orientation
        var kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
        
        nextButtonBotConstraint.constant = kbSize.height + 5
    }
    
    func keyboardWillHide(notification: NSNotification!) {
        nextButtonBotConstraint.constant = 5
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
        var dist = panGestureRecognizer.translationInView(view)
        var absVelocityX = abs(velocity.x)
        var absVelocityY = abs(velocity.y)
        var absDistX = abs(dist.x)
        var absDistY = abs(dist.y)
        var dir: Float
        
        if velocity.x < 0 {
            dir = -1.0
        } else {
            dir = 1.0
        }
        
        if sender.state == UIGestureRecognizerState.Began {
            initialPanPosition = point
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            //var tmpBetAmount = betTextField.text.toInt()!

            if absVelocityX > 20 && absVelocityY < 20 {
                
                println("absVelocityX = \(absVelocityX)")

                
                if absVelocityX > 20 {
                    if absVelocityX < 100 {
                        betAmount += 0.05 * dir
                    } else if absVelocityX < 150 {
                        betAmount += 0.5 * dir
                    } else if absVelocityX < 300 {
                        betAmount += 1.0 * dir
                    } else if absVelocityX < 500 {
                        betAmount += 5.0 * dir
                    } else if absVelocityX < 800 {
                        betAmount += 10.0 * dir
                    }
                }
                
//                var indx =  Int(round(absVelocityX/20))
//                
//                println("absDistX = \(absDistX)")
//                println("absVelocityX = \(absVelocityX)")
//                
//                if absVelocityX < 100 {
//                    betAmount += 0.05 * dir
//                } else if Int(absVelocityX) > amt.last {
//                    betAmount += Float(amt.last!) * dir
//                } else {
//                    betAmount += Float(amt[indx]) * dir
//                }
                
            
                if betAmount < 0 {
                    betAmount = 0
                }

                betTextField.text = "\(Int(round(betAmount)))"
            }
        
        }
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var result = true
        
        if textField == betTextField {
            if count(string) > 0 {
                let disallowedCharacterSet = NSCharacterSet(charactersInString: "0123456789").invertedSet
                let replacementStringIsLegal = string.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
                result = replacementStringIsLegal
            }
        }
        
        return result
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
