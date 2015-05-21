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
            
            var tmpBetAmount = betTextField.text.toInt()!

            if absVelocityX > 1 && absVelocityY < 20 {
                
                //var distX = abs((initialPanPosition?.x)! - point.x)
                
                if absVelocityX > 20 {
                    if absVelocityX < 200 {
                        tmpBetAmount += 1 * dir
                    } else if absVelocityX < 500 {
                        tmpBetAmount += 5 * dir
                    } else if absVelocityX < 800 {
                        tmpBetAmount += 10 * dir
                    } else if absVelocityX < 1000 {
                        tmpBetAmount += 50 * dir
                    }
                }
                if tmpBetAmount < 0 {
                    tmpBetAmount = 0
                }

                betTextField.text = "\(tmpBetAmount)"
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
