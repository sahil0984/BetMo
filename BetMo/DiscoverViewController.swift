//
//  DiscoverViewController.swift
//  BetMo
//
//  Created by Sahil Amoli on 10/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

    @IBOutlet weak var cardViewOne: CustomCellNib!
    @IBOutlet weak var cardViewTwo: CustomCellNib!
    @IBOutlet weak var noMoreBetsView: CustomCellNib!

    var superViewCenter: CGFloat!

    var activeCardView: CustomCellNib!
    var bets: [Bet] = [Bet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        superViewCenter = self.view.center.x
        noMoreBetsView.noContentView = true

        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        // Do any additional setup after loading the view.
        BetMoClient.sharedInstance.getAllDiscoverableBets({ (bets, error) -> () in
            if error == nil {
                self.bets = bets!
                println(self.bets)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                var bet = self.bets[0] as Bet
                println(bet.getDescription())
                self.cardViewOne.bet = self.bets[0]
                self.cardViewTwo.bet = self.bets[1]
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPan(panGestureRecognizer: UIPanGestureRecognizer) {
        let cardView = panGestureRecognizer.view! as CustomCellNib

        let point = panGestureRecognizer.locationInView(view)
        let velocity = panGestureRecognizer.velocityInView(view)
        let translation = panGestureRecognizer.translationInView(view)

        // Set up vars for what we care about
        let velocityX = velocity.x
        let currentCenterX = cardView.center.x
        let endPositionX = currentCenterX + translation.x
        
        if panGestureRecognizer.state == .Began {
            // We don't care about this
        } else if panGestureRecognizer.state == .Changed {
            // Update the position according to the pan
            cardView.center = CGPoint(x: endPositionX, y: cardView.center.y)
            panGestureRecognizer.setTranslation(CGPointZero, inView: self.view)
        } else if panGestureRecognizer.state == .Ended {
            // If the user ended with a negative velocity and surpassed our position threshold, move the card out of view to the left
            if velocityX < 0 && (currentCenterX + 100) < superViewCenter {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    cardView.center = CGPoint(x: -500, y: cardView.center.y)
                    panGestureRecognizer.setTranslation(CGPointZero, inView: self.view)
                    }, completion: { (Bool) -> Void in
                        self.updateCards(cardView)
                })
            } else if velocityX > 0 && superViewCenter < (currentCenterX - 100) {
                // If the user ended with a positive velocity and surpassed our position threshold, move the card out of view to the right
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    cardView.center = CGPoint(x: 500, y: cardView.center.y)
                    panGestureRecognizer.setTranslation(CGPointZero, inView: self.view)
                }, completion: { (Bool) -> Void in
                    self.updateCards(cardView)
                })
            } else {
                // The user didn't surpass our threshold of accepting or rejecting, move the card back into it's original position
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    cardView.center = CGPoint(x: self.superViewCenter, y: cardView.center.y)
                    panGestureRecognizer.setTranslation(CGPointZero, inView: self.view)
                })
            }
        }
    }

    func updateCards(removedCard: CustomCellNib) {
        bets.removeAtIndex(0)
        if bets.count < 2 {
            removedCard.removeFromSuperview()
        } else if cardViewOne == removedCard {
            cardViewOne.bet = bets[1]
            view.bringSubviewToFront(cardViewTwo)
            cardViewOne.center = CGPoint(x: self.superViewCenter, y: cardViewOne.center.y)
            self.view.layoutIfNeeded()
        } else {
            cardViewTwo.bet = bets[1]
            view.bringSubviewToFront(cardViewOne)
            cardViewTwo.center = CGPoint(x: self.superViewCenter, y: cardViewTwo.center.y)
        }
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
