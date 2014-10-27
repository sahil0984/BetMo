//
//  NewBetAmountViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol NewBetAmountViewControllerDelegate {
    func newBetAmountSubmitted(betAmount: Int)
}

class NewBetAmountViewController: UIViewController {

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var betAmountLabel: UILabel!
    
    var delegate: NewBetAmountViewControllerDelegate?
    
    var betAmount = 25
    
    var initialPanPosition: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func onNextButton(sender: AnyObject) {
        delegate?.newBetAmountSubmitted(betAmount)
    }
    
    
    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        var point = panGestureRecognizer.locationInView(view)
        var velocity = panGestureRecognizer.velocityInView(view)
        var absVelocityX = abs(velocity.x)
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
            
            if absVelocityX > 1 {
                
                if absVelocityX < 50 {
                    tmpBetAmount += 1 * dir
                } else if absVelocityX < 120 {
                    tmpBetAmount += 5 * dir
                } else if absVelocityX < 300 {
                    tmpBetAmount += 10 * dir
                } else if absVelocityX < 600 {
                    tmpBetAmount += 50 * dir
                }
                
                if tmpBetAmount >= 0 {
                    betAmount = tmpBetAmount
                }
            }
        
        } else if sender.state == UIGestureRecognizerState.Ended {
            
        }
        
        //println("At position: \(point)")
        //println("At velocity: \(absVelocityX)")
        
        //println("new amount: \(betAmount)")
        betAmountLabel.text = "$\(betAmount)"

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
