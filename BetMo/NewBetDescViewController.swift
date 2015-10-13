//
//  NewBetDescViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol NewBetDescViewControllerDelegate {
    func newBetDescSubmitted(betDesc: String)
}

class NewBetDescViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var betDescTextView: UITextView!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBotConstraint: NSLayoutConstraint!
    
    var delegate: NewBetDescViewControllerDelegate?
    
    let betDefaultText = "Describe your bet..."
    var betDescTextLength = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        betDescTextView.font = UIFont(name: "OpenSans-Semibold", size: 30)
        nextButton.titleLabel!.font = UIFont(name: "OpenSans-Regular", size: 15)
        
        betDescTextView.delegate = self
        betDescTextView.text = ""
        AddEmptyBetHint()
        betDescTextLength = 0
        
        nextButton.layer.cornerRadius = 5
        nextButton.hidden = true
        
        betDescTextView.becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification!) {
        var userInfo = notification.userInfo!
        
        // Get the keyboard height and width from the notification
        // Size varies depending on OS, language, orientation
        let kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
        
        nextButtonBotConstraint.constant = kbSize.height + 5
    }
    
    func keyboardWillHide(notification: NSNotification!) {
        nextButtonBotConstraint.constant = 5
    }
    
    
    @IBAction func onNextButton(sender: AnyObject) {
        delegate?.newBetDescSubmitted(betDescTextView.text)
    }
    
    
    func AddEmptyBetHint() {
        let betTextLength = betDescTextView.text as NSString
        if betTextLength.length == 0 {
            betDescTextView.text = betDefaultText
            setHintFont()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let betText = betDescTextView.text as NSString
        betDescTextLength = betText.length
        
        if betDescTextLength == 0 {
            nextButton.hidden = true
        } else {
            nextButton.hidden = false
        }
        
//        descCharCountLabel.text = "\(140 - betDescTextLength)"
//        if betDescTextLength > 140 {
//            descCharCountLabel.textColor = UIColor.redColor()
//        } else {
//            descCharCountLabel.textColor = UIColor.blackColor()
//        }
    }
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        setBetFont()
        
        if betDescTextLength == 0 {
            betDescTextView.text = ""
        }
        return true
    }
    
    func setHintFont() {
        betDescTextView.textColor = UIColor.grayColor()
    }
    func setBetFont() {
        betDescTextView.textColor = UIColor.blackColor()
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
