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
                let currentUser = PFUser.currentUser() as! User
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

                if winner != nil {
                    self.feedBets.append(bet)
                }

                ////////// END Feed Tab //////////

                ////////// Discover Tab //////////

                // Open Bets -- bets that don't have an opponent and the owner isn't the current User
                
                if owner.getFbId() != currentUser.getFbId() && opponent == nil {
                    
                    let lastOpenBetAt = currentUser.getLastOpenBetAt() as NSDate?
                    let betCreatedDate = bet.createdAt as NSDate!
                    let compareResult = lastOpenBetAt!.compare(betCreatedDate) as NSComparisonResult
                    //println("lastOpenBetActionAt: \(lastOpenBetAt)")
                    //println("betCreatedDate: \(betCreatedDate)")
                    
                    if compareResult == NSComparisonResult.OrderedDescending {
                        //println("last open bet action is older than this bet creation")
                        self.openBets.append(bet)
                    }
                    
                }

                ////////// End Discover Tab //////////

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
        BetMoClient.sharedInstance.getAllBetMoFriends({(friendsList, error) -> () in
            if error == nil {
                
                let friendOwnerQuery = PFQuery(className: "Bet")
                friendOwnerQuery.whereKey("owner", containedIn: friendsList!)

                let friendOpponentQuery = PFQuery(className: "Bet")
                friendOpponentQuery.whereKey("opponent", containedIn: friendsList!)
                
                let betsQuery = PFQuery.orQueryWithSubqueries([friendOwnerQuery, friendOpponentQuery])
                
                betsQuery.includeKey("owner")
                betsQuery.includeKey("opponent")
                betsQuery.includeKey("winner")
                betsQuery.orderByDescending("updatedAt")
                betsQuery.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if let error = error {
                        completion(bets: nil, error: error)
                    } else {
                        self.allBets = objects as! [Bet]
                        
                        print("found \(self.allBets.count) bets")
                        
                        completion(bets: self.allBets, error: nil)
                    }
                }
                
            } else {
                print(error)
            }
        })
        
    }

    func getTotalWinsForUser(user: User, completion: (winCount: Int?, error: NSError?) -> ()) {
        
        let ownerBetsQuery = PFQuery(className: "Bet")
        ownerBetsQuery.whereKey("owner", equalTo: user)
        
        let opponentBetsQuery = PFQuery(className: "Bet")
        opponentBetsQuery.whereKey("opponent", equalTo: user)
        
        let mainQuery = PFQuery.orQueryWithSubqueries([ownerBetsQuery, opponentBetsQuery])
        
        mainQuery.whereKey("winner", equalTo: user)
        
        mainQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print(error)
                completion(winCount: nil, error: error)
            } else {
                let winningBets = objects as! [Bet]
                completion(winCount: winningBets.count, error: nil)
            }
        }
    }

    func getTotalLossesForUser(user: User, completion: (lossCount: Int?, error: NSError?) -> ()) {
        
        let ownerBetsQuery = PFQuery(className: "Bet")
        ownerBetsQuery.whereKey("owner", equalTo: user)
        
        let opponentBetsQuery = PFQuery(className: "Bet")
        opponentBetsQuery.whereKey("opponent", equalTo: user)
        
        let mainQuery = PFQuery.orQueryWithSubqueries([ownerBetsQuery, opponentBetsQuery])
        
        mainQuery.whereKeyExists("winner")
        mainQuery.whereKey("winner", notEqualTo: user)
        
        mainQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print(error)
                completion(lossCount: nil, error: error)
            } else {
                let losingBets = objects as! [Bet]
                completion(lossCount: losingBets.count, error: nil)
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
    
    func updateMyLastOpenBetAt(bet: Bet) {
        let currUser = PFUser.currentUser() as! User
        currUser.setLastOpenBetAt(bet.createdAt!)
        currUser.saveInBackground()
    }
    
    
    
    //function to get all the friends in your facebook network using BetMo
    
    //func getAllBetMoFriends(completion: (betMoFriendsList: [User]?, inviteFriendsList: [User]?, error: NSError?) -> ()) {
    func getAllBetMoFriends(completion: (betMoFriendsList: [User]?, error: NSError?) -> ()) {
        // Issue a Facebook Graph API request to get your user's friend list
        
//        FBRequestConnection.startWithGraphPath("/me/invitable_friends", parameters: nil, HTTPMethod: "GET") { (connection, result, error: NSError!) -> Void in
            //Add code
        //}
        FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "email"]).startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
        
        //FBRequestConnection.startForMyFriendsWithCompletionHandler{ (connection, result, error: NSError!) -> Void in
            if let error = error {
                print("Error requesting friends list form facebook")
                print("\(error)")
                completion(betMoFriendsList: nil, error: error)
            } else {
                // result will contain an array with your user's friends in the "data" key
                let friendObjects = result["data"] as! [NSDictionary]
                
                var allFbFriendIds: [String] = []
                var allFbFriends: [User] = []
                
                // Create a list of friends' Facebook IDs
                for friendObject in friendObjects {
                    allFbFriendIds.append(friendObject["id"] as! String)
                    //allFbFriends.append(friendObject as User)
                }
                
                print("All FB Friends: \(friendObjects)")
                
                // Issue a Parse query to filter the list by users using BetMo
                let friendsQuery = PFQuery(className: "_User")
                friendsQuery.whereKey("fbId", containedIn: allFbFriendIds)
                //friendsQuery.whereKey("searchName", hasPrefix: friendSearchBar.text.lowercaseString)
                friendsQuery.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if let error = error {
                        print("Error finding")
                        completion(betMoFriendsList: nil, error: error)
                    } else {
                        let friends = objects as! [User]
                        var friendsList: [User]!
                        if friends.count == 0 {
                            //println("Not Found: \(self.friendSearchBar.text)")
                            friendsList = []
                        } else {
                            //println("Found: \(self.friendSearchBar.text)")
                            friendsList = friends
                        }
                        completion(betMoFriendsList: friendsList, error: nil)
                        //println("obtained friends list")
                    }
                }
                
                
                print("\(friendObjects.count)")
            }
        }
    }
}