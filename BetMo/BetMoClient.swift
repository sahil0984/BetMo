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

    var allBets: [Bet] = [Bet]() {
        willSet(bets) {
            self.resetAllCachedBets()
            
            for bet in bets {
                let currentUser = PFUser.currentUser() as User
                let owner = bet.getOwner()
                let winner = bet.getWinner()
                let opponent = bet.getOppenent()

                ////////// Requests Tab //////////
                
                // Requests to Current User
                if opponent != nil && opponent?.getFbId() == currentUser.getFbId() && bet.getIsAccepted() == false {
                    self.requestedBets.append(bet)
                }
                // Request from Current User (if there is no opponent or if the opponent hasn't yet accepted)
                if owner.getFbId() == currentUser.getFbId() && (opponent == nil || (opponent != nil && bet.getIsAccepted() == false)) {
                    self.requestedBets.append(bet)
                }

                ////////// END Requests Tab //////////

                ////////// Feed Tab //////////

                // Open Bets -- bets that don't have an opponent and the owner isn't the current User
                if owner.getFbId() != currentUser.getFbId() && opponent == nil {
                    self.openBets.append(bet)
                }

                if winner != nil {
                    self.feedBets.append(bet)
                }

                ////////// END Feed Tab //////////
                
                ////////// Profile Tab //////////

                // Bet must be accepted to show up in my profile
                if  bet.getIsAccepted() == true {
                    if owner.getFbId() == currentUser.getFbId() || (opponent != nil && opponent?.getFbId() == currentUser.getFbId()) {
                        self.profileBets.append(bet)
                    }
                }

                ////////// END Profile Tab //////////


                // @TODO: NO LONGER NEEDED REMOVE REFERENCES

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

            }
        }
    }
    var myBets: [Bet] = [Bet]()
    var openBets: [Bet] = [Bet]()
    var betsWithNoWinner: [Bet] = [Bet]()
    var betsNotAccepted: [Bet] = [Bet]()
    var betsCompleted: [Bet] = [Bet]()
    
    // New stuff
    var requestedBets: [Bet] = [Bet]()
    var feedBets: [Bet] = [Bet]()
    var profileBets: [Bet] = [Bet]()
    
    func getAllBets(completion: (bets: [Bet]?, error: NSError?) -> ()) {
        var betsQuery = PFQuery(className: "Bet")
        betsQuery.includeKey("owner")
        betsQuery.includeKey("opponent")
        betsQuery.includeKey("winner")
        betsQuery.orderByDescending("updatedAt")
        betsQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.allBets = objects as [Bet]

                completion(bets: self.allBets, error: nil)
            } else {
                completion(bets: nil, error: error)
            }
        }
    }
    
    func getTotalWinsForUser(user: User, completion: (winCount: Int?, error: NSError?) -> ()) {
        
        var ownerBetsQuery = PFQuery(className: "Bet")
        ownerBetsQuery.whereKey("owner", equalTo: user)
        
        var opponentBetsQuery = PFQuery(className: "Bet")
        opponentBetsQuery.whereKey("opponent", equalTo: user)
        
        var mainQuery = PFQuery.orQueryWithSubqueries([ownerBetsQuery, opponentBetsQuery])
        
        mainQuery.whereKey("winner", equalTo: user)
        
        mainQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var winningBets = objects as [Bet]
                completion(winCount: winningBets.count, error: nil)
            } else {
                println(error)
                completion(winCount: nil, error: error)
            }
        }
    }
    
    func getTotalLossesForUser(user: User, completion: (lossCount: Int?, error: NSError?) -> ()) {
        
        var ownerBetsQuery = PFQuery(className: "Bet")
        ownerBetsQuery.whereKey("owner", equalTo: user)
        
        var opponentBetsQuery = PFQuery(className: "Bet")
        opponentBetsQuery.whereKey("opponent", equalTo: user)
        
        var mainQuery = PFQuery.orQueryWithSubqueries([ownerBetsQuery, opponentBetsQuery])
        
        mainQuery.whereKeyExists("winner")
        mainQuery.whereKey("winner", notEqualTo: user)
        
        mainQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var losingBets = objects as [Bet]
                completion(lossCount: losingBets.count, error: nil)
            } else {
                println(error)
                completion(lossCount: nil, error: error)
            }
        }
        
    }
    
    func resetAllCachedBets() {
        // reset values
        self.openBets = [Bet]()
        self.betsCompleted = [Bet]()
        self.myBets = [Bet]()

        self.requestedBets = [Bet]()
        self.feedBets = [Bet]()
        self.profileBets = [Bet]()
    }
    
    func getAllRequestedBets() -> [Bet] {
        return self.requestedBets
    }

    func getAllDiscoverableBets(completion: (bets: [Bet]?, error: NSError?) -> ()) {
        if self.openBets.count > 0 {
            completion(bets: self.openBets, error: nil)
        } else {
            self.getAllBets({ (bets, error) -> () in
                completion(bets: self.openBets, error: error)
            })
        }
        
    }
}