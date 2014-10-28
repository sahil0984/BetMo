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

    @IBOutlet weak var acceptedLabel: UILabel!
    @IBOutlet weak var rejectedLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var buttonsContainer: UIView!

    var superViewCenter: CGFloat!
    var currentRotation: CGFloat = 0

    var activeCardView: CustomCellNib!
    var bets: [Bet] = [Bet]()

    // How much the last card is rotated to show "stacked" cards
    let lastCardRotationDegress = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont(name: "OpenSans-Light", size: 20)
        superViewCenter = self.view.center.x
        noMoreBetsView.noContentView = true

        var lastCardRotation = -1 * CGFloat(Double(lastCardRotationDegress) * M_PI / 180)
        noMoreBetsView.transform = CGAffineTransformRotate(noMoreBetsView.transform, lastCardRotation)

//        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        // Do any additional setup after loading the view.
        BetMoClient.sharedInstance.getAllDiscoverableBets({ (bets, error) -> () in
            if error == nil {
                self.bets = bets!
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                var bet = self.bets[0] as Bet
                self.cardViewOne.bet = self.bets[0]
                self.cardViewTwo.bet = self.bets[1]
                self.activeCardView = self.cardViewOne
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

        var labelAlpha: CGFloat = 0
        if superViewCenter < currentCenterX {
            labelAlpha = -1 * (1 - endPositionX/superViewCenter)
        } else if superViewCenter > currentCenterX {
            labelAlpha = 1 - endPositionX/superViewCenter
        }

        if panGestureRecognizer.state == .Began {
            // We don't care about this
        } else if panGestureRecognizer.state == .Changed {
            // Update the position according to the pan
            cardView.center = CGPoint(x: endPositionX, y: cardView.center.y)
            panGestureRecognizer.setTranslation(CGPointZero, inView: self.view)

            var rotation = CGFloat(Double( translation.x/20) * M_PI / 180)
            // Rotate the card
            cardView.transform = CGAffineTransformRotate(cardView.transform, rotation)
            // Add to the current rotation value
            currentRotation += rotation

            var scale = (1-labelAlpha) * 2
            if scale < 1 {
                scale = 1
            }
            var stamp = -1 * CGFloat(Double(10) * M_PI / 180)
            // Show rejection/acceptance label
            if currentCenterX < superViewCenter {
                cardView.rejectedStampLabel.alpha = labelAlpha
                cardView.rejectedStampLabel.transform = CGAffineTransformMakeScale(scale, scale)
                cardView.rejectedStampLabel.transform = CGAffineTransformRotate(cardView.rejectedStampLabel.transform, stamp)
                cardView.acceptedStampLabel.alpha = 0
            } else if superViewCenter < currentCenterX {
                cardView.acceptedStampLabel.transform = CGAffineTransformMakeScale(scale, scale)
                cardView.acceptedStampLabel.transform = CGAffineTransformRotate(cardView.acceptedStampLabel.transform, stamp)
                cardView.rejectedStampLabel.alpha = 0
                cardView.acceptedStampLabel.alpha = labelAlpha
            }
        } else if panGestureRecognizer.state == .Ended {
            if velocityX < 0 && (currentCenterX + 100) < superViewCenter {
                handleRejection()

                // If the user ended with a negative velocity and surpassed our position threshold, move the card out of view to the left
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    cardView.center = CGPoint(x: -500, y: cardView.center.y)
                    panGestureRecognizer.setTranslation(CGPointZero, inView: self.view)
                    }, completion: { (Bool) -> Void in
                        self.updateCards(cardView)
                        // Undo rotation of the card
                        cardView.transform = CGAffineTransformRotate(cardView.transform, (-1 * self.currentRotation))
                        self.currentRotation = 0
                })
            } else if velocityX > 0 && superViewCenter < (currentCenterX - 100) {
                handleAcceptance()

                // If the user ended with a positive velocity and surpassed our position threshold, move the card out of view to the right
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    cardView.center = CGPoint(x: 500, y: cardView.center.y)
                    panGestureRecognizer.setTranslation(CGPointZero, inView: self.view)
                }, completion: { (Bool) -> Void in
                    self.updateCards(cardView)
                    // Undo rotation of the card
                    cardView.transform = CGAffineTransformRotate(cardView.transform, (-1 * self.currentRotation))
                    self.currentRotation = 0
                })
            } else {
                // The user didn't surpass our threshold of accepting or rejecting, move the card back into it's original position
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    // Reset everything
                    cardView.rejectedStampLabel.alpha = 0
                    cardView.acceptedStampLabel.alpha = 0
                    cardView.center = CGPoint(x: self.superViewCenter, y: cardView.center.y)
                    panGestureRecognizer.setTranslation(CGPointZero, inView: self.view)

                    // Undo rotation of the card
                    cardView.transform = CGAffineTransformRotate(cardView.transform, (-1 * self.currentRotation))
                    self.currentRotation = 0
                })
            }
        }
    }

    func updateCards(removedCard: CustomCellNib) {
        bets.removeAtIndex(0)

        if bets.count < 2 {
            if cardViewOne == removedCard {
                activeCardView = cardViewTwo
            } else {
                activeCardView = cardViewOne
            }
            removedCard.removeFromSuperview()
        } else if cardViewOne == removedCard {
            activeCardView = cardViewTwo
            cardViewOne.bet = bets[1]
            view.bringSubviewToFront(cardViewTwo)
            cardViewOne.center = CGPoint(x: self.superViewCenter, y: cardViewOne.center.y)
            self.view.layoutIfNeeded()
        } else {
            activeCardView = cardViewOne
            cardViewTwo.bet = bets[1]
            view.bringSubviewToFront(cardViewOne)
            cardViewTwo.center = CGPoint(x: self.superViewCenter, y: cardViewTwo.center.y)
        }
    }

    func handleRejection() {
        handleLastBetCase()

        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.activeCardView.rejectedStampLabel.alpha = 1
            self.activeCardView.rejectedStampLabel.transform = CGAffineTransformMakeScale(0.33, 0.33)
            }, completion: { (Bool) -> Void in
                self.activeCardView.rejectedStampLabel.alpha = 0
        })
    }

    func handleAcceptance() {
        handleLastBetCase()

        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.activeCardView.acceptedStampLabel.alpha = 1
            self.activeCardView.acceptedStampLabel.transform = CGAffineTransformMakeScale(0.33, 0.33)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.activeCardView.acceptedStampLabel.alpha = 0
                })
        })
    }

    @IBAction func handleTapReject(sender: UITapGestureRecognizer) {
        handleRejection()
        self.currentRotation = -1 * CGFloat(Double(5) * M_PI / 180)
        self.activeCardView.transform = CGAffineTransformRotate(self.activeCardView.transform, self.currentRotation)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.activeCardView.center.x -= 500
            }, completion: { (Bool) -> Void in
                // Undo rotation of the card
                self.activeCardView.transform = CGAffineTransformRotate(self.activeCardView.transform, (-1 * self.currentRotation))
                self.currentRotation = 0
                self.updateCards(self.activeCardView)
        })
    }
    
    @IBAction func handleTapAcceptance(sender: UITapGestureRecognizer) {
        handleAcceptance()
        self.currentRotation = CGFloat(Double(5) * M_PI / 180)
        self.activeCardView.transform = CGAffineTransformRotate(self.activeCardView.transform, self.currentRotation)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.activeCardView.center.x += 500
            }, completion: { (Bool) -> Void in
                // Undo rotation of the card
                self.activeCardView.transform = CGAffineTransformRotate(self.activeCardView.transform, (-1 * self.currentRotation))
                self.currentRotation = 0
                self.updateCards(self.activeCardView)
        })
    }

    func handleLastBetCase() {
        if bets.count == 1 {
            // Remove rotation of last card
            var lastCardRotation = CGFloat(Double(lastCardRotationDegress) * M_PI / 180)
            noMoreBetsView.transform = CGAffineTransformRotate(noMoreBetsView.transform, lastCardRotation)

            // We have accepted/rejected the very last bet, hide action buttons
            buttonsContainer.hidden = true
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
