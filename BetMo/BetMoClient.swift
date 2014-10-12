//
//  BetMoClient.swift
//  BetMo
//
//  Created by Sahil Amoli on 10/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class BetMoClient {
    class var sharedInstance: BetMoClient {
        struct Static {
            static let instance = BetMoClient()
        }
        return Static.instance
    }

    var allBets: [Bet] = [Bet]()
    var myBets: [Bet] = [Bet]()
    var openBets: [Bet] = [Bet]()
    var betsWithNoWinner: [Bet] = [Bet]()
    var betsNotAccepted: [Bet] = [Bet]()
    var betsCompleted: [Bet] = [Bet]()
    
    func getAllBets(completion: (bets: [Bet]?, error: NSError?) -> ()) {
        var betsQuery = PFQuery(className: "Bet")
        betsQuery.includeKey("owner")
        betsQuery.includeKey("opponent")
        betsQuery.includeKey("winner")
        betsQuery.orderByDescending("createdAt")
        betsQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var bets = objects as [Bet]
                for bet in bets {
                    let currentUser = PFUser.currentUser() as User
                    let owner = bet.getOwner()
                    let winner = bet.getWinner()
                    let opponent = bet.getOppenent()

                    // Open Bets -- bets that don't have an opponent and the owner isn't the current User
                    if owner.getFbId() != currentUser.getFbId() && opponent == nil {
                        self.openBets.append(bet)
                    }

                    // Completed bets! Was accepted and has a winner!
                    if bet.getIsAccepted() && winner != nil {
                        self.betsCompleted.append(bet)
                    }

                    if owner.getFbId() == currentUser.getFbId() {
                        self.myBets.append(bet)
                    } else if opponent != nil {
                        if opponent?.getFbId() == currentUser.getFbId() {
                            self.myBets.append(bet)
                        }
                    }
//
//                    // Bet has an opponent, was accepted, but just no winner has been decided
//                    if bet.getIsAccepted() && opponent != nil && winner == nil {
//                        self.betsWithNoWinner.append(bet)
//                    }
//
//                    // If a bet hasn't been accepted and has an opponent -- show it in "Pending Bets under My Bets"
//                    if bet.getIsAccepted() == false && opponent != nil {
//                        self.betsNotAccepted.append(bet)
//                    }
                }
                completion(bets: bets, error: nil)
            } else {
                completion(bets: nil, error: error)
            }
        }
    }

    func getAllBetsForUser(userId: String?, completion: (bets: [Bet], error: NSError?) -> ()) {

    }
    
}