//
//  Bet.swift
//  BetMo
//
//  Created by Sahil Arora on 10/9/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class Bet : PFObject, PFSubclassing {

    //Only getter for objectId. No setter since it is generated only by Parse
    func getObjectId() -> String {
        return self.objectId as String!
    }
    
    func getOwner() -> User {
        return self["owner"] as! User
    }
    
    func setOwner(owner: User) {
        self["owner"] = owner
    }
    
    func getOppenent() -> User? {
        return self["opponent"] as? User
    }
    
    func setOpponent(opponent: User) {
        self["opponent"] = opponent
    }
    
    func getWinner() -> User? {
        return self["winner"] as? User
    }
    
    func setWinner(winner: User) {
        self["winner"] = winner
    }
    
    func getDescription() -> String? {
        return self["description"] as? String
    }
    
    func setDescription(description: String) {
        self["description"] = description
    }

    func getAmount() -> String? {
        return self["amount"] as? String
    }

    func setAmount(amount: String) {
        self["amount"] = amount
    }

    func getIsAccepted() -> Bool {
        return self["isAccepted"] as! Bool
    }

    func setIsAccepted(isAccepted: Bool) {
        self["isAccepted"] = isAccepted
    }

    
    func getWatcherList() -> [User]? {
        return self["watcherList"] as? [User]
    }
    
    func setWatcherList(watcher: User) {
        self.addObject(watcher, forKey: "watcherList")
    }
    
    func getWatcherListCount() -> Int {
        if let watcherListCount = getWatcherList()?.count {
            return watcherListCount
        }
        return 0
    }

    func getCreatedAt() -> String {
        if self.createdAt == nil {
            return "0m"
        }

        let now = NSDate()
        let t = now.timeIntervalSinceDate(self.createdAt!)
        let d: Int = Int(t)/86400

        if d > 0 {
            return "\(d)d"
        } else {
            let h: Int = Int(t)/3600
            if h>0 {
                return "\(h)h"
            } else {
                let m: Int = Int(t)/60
                return "\(m)m"
            }
        }
    }
    
    func create() {
        let currentUser = PFUser.currentUser() as! User
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                print("Successfully created bet");
                
                let returnedObjectId = self.getObjectId()
                
                //Create a channel for push notifications in current installation
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject("ch_\(returnedObjectId)", forKey: "channels")
                currentInstallation.saveInBackground()
                
                
                if let opponent = self.getOppenent() {
                    //Find opponent
                    let opponentQuery = User.query()
                    opponentQuery!.whereKey("fbId", equalTo: opponent.getFbId()!)
                    //Find devices associated with the opponent
                    let pushQuery = PFInstallation.query()
                    pushQuery!.whereKey("user", matchesQuery: opponentQuery!)
                    //Send push notification to opponent
                    
                    let data = [  "alert": "\(currentUser.getName()) has challenged you to a $\(self.getAmount()!) bet.\n\(self.getDescription()!)",
                                  "badge": "Increment",
                                  "notifyType": "create" ]
                    
                    let push = PFPush()
                    push.setQuery(pushQuery)
                    push.setData(data)
                    push.sendPushInBackground()

                }
                
            } else {
                print("Failed creating the bet");
                print("\(error!)")
            }
        }
    }
    
    func acceptWithCompletion(completion: (bet: Bet?, error: NSError?) -> ()) {
        let currentUser = PFUser.currentUser() as! User
        setOpponent(currentUser)
        setIsAccepted(true)
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                print("Successfully accepted bet");
                completion(bet: (self as Bet), error: nil)
                //Create a channel for push notifications in current installation
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject("ch_\(self.getObjectId())", forKey: "channels")
                currentInstallation.saveInBackground()
                
                
                //Find owner
                let ownerQuery = User.query()
                ownerQuery!.whereKey("fbId", equalTo: self.getOwner().getFbId()!)
                //Find devices associated with the owner
                let pushQuery = PFInstallation.query()
                pushQuery!.whereKey("user", matchesQuery: ownerQuery!)
                //Send push notification to opponent
                
                let data: NSDictionary = [  "alert": "\(currentUser.getName()) has accepted your bet.\n\(self.getDescription()!)",
                                            "badge": "Increment",
                                            "notifyType": "accept" ]
                
                let push = PFPush()
                push.setQuery(pushQuery)
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
                
                
            } else {
                print("Failed to accept bet");
                completion(bet: nil, error: error)
                print("\(error!)")
            }
        }
    }

    func accept() {
        let currentUser = PFUser.currentUser() as! User
        setOpponent(currentUser)
        setIsAccepted(true)
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                print("Successfully accepted bet");
                
                //Create a channel for push notifications in current installation
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject("ch_\(self.getObjectId())", forKey: "channels")
                currentInstallation.saveInBackground()
                
                
                //Find owner
                let ownerQuery = User.query()
                ownerQuery!.whereKey("fbId", equalTo: self.getOwner().getFbId()!)
                //Find devices associated with the owner
                let pushQuery = PFInstallation.query()
                pushQuery!.whereKey("user", matchesQuery: ownerQuery!)
                //Send push notification to opponent
                
                let data: NSDictionary = [  "alert": "\(currentUser.getName()) has accepted your bet.\n\(self.getDescription()!)",
                                            "badge": "Increment",
                                            "notifyType": "accept" ]
                
                let push = PFPush()
                push.setQuery(pushQuery)
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
                
                
            } else {
                print("Failed to accept bet");
                print("\(error!)")
            }
        }
    }

    // For now remove the current user as the opponent when they reject the bet
    func reject() {
        cancel()
    }

    func cancel() {
        self.deleteInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                print("Successfully deleted bet");
                
                //Delete a channel for push notifications in current installation
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.removeObject("ch_\(self.getObjectId())", forKey: "channels")
                currentInstallation.saveInBackground()

            } else {
                print("Failed to delete bet");
                print("\(error!)")
            }
        }
    }
    
    func lost() {
        let currentUser = PFUser.currentUser() as! User
        if currentUser.getFbId() == self.getOwner().getFbId() {
            self["winner"] = self.getOppenent()!
        } else {
            self["winner"] = self.getOwner()
        }

        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                print("Successfully saved that I lost");
                
                self.pushWinnerToWatchers()
                
                //Find owner
                let ownerQuery = User.query()
                if self.getOwner().objectId == currentUser.objectId {
                    ownerQuery!.whereKey("fbId", equalTo: (self.getOppenent()?.getFbId())!)
                } else {
                    ownerQuery!.whereKey("fbId", equalTo: self.getOwner().getFbId()!)
                }
                //Find devices associated with the owner
                let pushQuery = PFInstallation.query()
                pushQuery!.whereKey("user", matchesQuery: ownerQuery!)
                //Send push notification to opponent
                
                let data: NSDictionary = [  "alert": "You have won a $\(self.getAmount()!) bet against \(currentUser.getName()).\n\(self.getDescription()!)",
                                            "badge": "Increment",
                                            "notifyType": "winner" ]
                
                let push = PFPush()
                push.setQuery(pushQuery)
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
                
            } else {
                print("Failed to save that I lost");
                print("\(error!)")
            }
        }
    }

    func lostWithCompletion(completion: (bet: Bet?, error: NSError?) -> ()) {
        let currentUser = PFUser.currentUser() as! User
        if currentUser.getFbId() == self.getOwner().getFbId() {
            self["winner"] = self.getOppenent()!
        } else {
            self["winner"] = self.getOwner()
        }
        
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                print("Successfully saved that I lost");
                completion(bet: (self as Bet), error: nil)

                self.pushWinnerToWatchers()
                
                //Find owner
                let ownerQuery = User.query()
                if self.getOwner().objectId == currentUser.objectId {
                    ownerQuery!.whereKey("fbId", equalTo: (self.getOppenent()?.getFbId())!)
                } else {
                    ownerQuery!.whereKey("fbId", equalTo: self.getOwner().getFbId()!)
                }
                //Find devices associated with the owner
                let pushQuery = PFInstallation.query()
                pushQuery!.whereKey("user", matchesQuery: ownerQuery!)
                //Send push notification to opponent
                
                let data: NSDictionary = [  "alert": "You have won a $\(self.getAmount()!) bet against \(currentUser.getName()).\n\(self.getDescription()!)",
                                            "badge": "Increment",
                                            "notifyType": "winner" ]
                
                let push = PFPush()
                push.setQuery(pushQuery)
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
                
            } else {
                completion(bet: nil, error: error)
                print("Failed to save that I lost");
                print("\(error!)")
            }
        }
    }
    func won() {
        let currentUser = PFUser.currentUser() as! User
        self["winner"] = currentUser
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                print("Successfully saved that I won");
                
                self.pushWinnerToWatchers()
                
                //Find owner
                let ownerQuery = User.query()
                if self.getOwner().objectId == currentUser.objectId {
                    ownerQuery!.whereKey("fbId", equalTo: (self.getOppenent()?.getFbId())!)
                } else {
                    ownerQuery!.whereKey("fbId", equalTo: self.getOwner().getFbId()!)
                }
                //Find devices associated with the owner
                let pushQuery = PFInstallation.query()
                pushQuery!.whereKey("user", matchesQuery: ownerQuery!)
                //Send push notification to opponent
                
                let data: NSDictionary = [  "alert": "You have lost a $\(self.getAmount()!) bet against \(currentUser.getName()).\n\(self.getDescription()!)",
                                            "badge": "Increment",
                                            "notifyType": "loser" ]
                
                let push = PFPush()
                push.setQuery(pushQuery)
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
                
            } else {
                print("Failed to save that I won");
                print("\(error!)")
            }
        }
    }

    func wonWithCompletion(completion: (bet: Bet?, error: NSError?) -> ()) {
        let currentUser = PFUser.currentUser() as! User
        self["winner"] = currentUser
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                print("Successfully saved that I won");
                completion(bet: (self as Bet), error: nil)

                self.pushWinnerToWatchers()
                
                //Find owner
                let ownerQuery = User.query()
                if self.getOwner().objectId == currentUser.objectId {
                    ownerQuery!.whereKey("fbId", equalTo: (self.getOppenent()?.getFbId())!)
                } else {
                    ownerQuery!.whereKey("fbId", equalTo: self.getOwner().getFbId()!)
                }
                //Find devices associated with the owner
                let pushQuery = PFInstallation.query()
                pushQuery!.whereKey("user", matchesQuery: ownerQuery!)
                //Send push notification to opponent
                
                let data: NSDictionary = [  "alert": "You have lost a $\(self.getAmount()!) bet against \(currentUser.getName()).\n\(self.getDescription()!)",
                                            "badge": "Increment",
                                            "notifyType": "loser" ]
                
                let push = PFPush()
                push.setQuery(pushQuery)
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
                
            } else {
                completion(bet: nil, error: error)
                print("Failed to save that I won");
                print("\(error!)")
            }
        }
    }

    func watch() {
        let currentUser = PFUser.currentUser() as! User
        self.addObject(currentUser, forKey: "watcherList")
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                print("Successfully saved user to watcher list");

                //Send push notification to owner and opponent
                
                let data: NSDictionary = [  "alert": "\(currentUser.getName()) is watching your bet.\n\(self.getDescription()!)",
                                            "badge": "Increment",
                                            "notifyType": "watch" ]
                
                let push = PFPush()
                push.setChannel("ch_\(self.getObjectId())")
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
                
                
            } else {
                print("Failed to save user to watcher list");
                print("\(error!)")
            }
        }
    }
    
    func unWatch() {
        let currentUser = PFUser.currentUser() as! User
        self.removeObject(currentUser, forKey: "watcherList")
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                print("Successfully removed user from watcher list");
            } else {
                print("Failed to remove user from watcher list");
                print("\(error!)")
            }
        }
    }

    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Bet"
    }
    
//    static func parseClassName() -> String! {
//        return "Bet"
//    }
    
    //Handy functions to check the type of the bet:
    //There are 4 types of bets:
    //1. Open bets
    //2. Pending accept bets
    //3. Undecided bets
    //4. Closed bets
    
    func isOpenBet() -> Bool {
        let isOpen = (self.getOppenent() == nil)
        return isOpen
    }
    
    func isPendingAcceptBet() -> Bool {
        let isPendingAccept =  (self.getIsAccepted() == false)
                            && (self.getOppenent() != nil)
        return isPendingAccept
    }
    
    func isUndecidedBet() -> Bool {
        let isUndecided =  (self.isOpenBet() == false)
                        && (self.isPendingAcceptBet() == false)
                        && (self.getWinner() == nil)
                        && (self.getIsAccepted() == true)
        
        return isUndecided
    }
    
    func isClosedBet() -> Bool {
        let isClosed =  (self.isOpenBet() == false)
                     && (self.isPendingAcceptBet() == false)
                     && (self.isUndecidedBet() == false)
                     && (self.getWinner() != nil)
        
        return isClosed
    }
    
    //Handy functions to check:
    //1. Current user is Bet Owner
    //2. Current user is Bet Opponent
    //3. Current user subscribed to bet
    func isUserOwner() -> Bool {
        let currUser = PFUser.currentUser() as! User
        let isOwner = currUser.getFbId() == self.getOwner().getFbId()
        
        return isOwner
    }
    func isUserOpponent() -> Bool {
        let currUser = PFUser.currentUser() as! User
        let isOpponent = currUser.getFbId() == self.getOppenent()?.getFbId()
        
        return isOpponent
    }
    func isUserWatcher() -> Bool {
        let currUser = PFUser.currentUser() as! User
        
        if let watcherList = getWatcherList() {
            for watcher in watcherList {
                if watcher.objectId == currUser.objectId {
                    return true
                }
            }
        }
        return false
    }
    func isOpponentWinner() -> Bool {
        let opponent = getOppenent()
        let winner = getWinner()

        return (opponent != nil && winner != nil && (opponent?.objectId == winner?.objectId))
    }

    func isOwnerWinner() -> Bool {
        let owner = getOwner()
        let winner = getWinner()
        
        return (winner != nil && (owner.objectId == winner?.objectId))
    }
    
    
    //Push Notification helper functions:
    //------------------------------------
    //Push bet decision to watchers
    func pushWinnerToWatchers() {
        let currentUser = PFUser.currentUser() as! User
        
        let watchersList = self.getWatcherList()
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", containedIn: watchersList!)
        pushQuery!.whereKey("user", notEqualTo: currentUser) //When using multiple whereKey it acts like AND
        

        var winnerUser = User()
        var loserUser = User()
        if self.getOppenent()?.objectId == self.getWinner()?.objectId {
            winnerUser = self.getOwner()
            loserUser = self.getOppenent()!
        } else {
            winnerUser = self.getOppenent()!
            loserUser = self.getOwner()
        }
        
        let data: NSDictionary = [  "alert": "\(winnerUser.getName()) has won the bet against \(loserUser.getName()).\n\(self.getDescription()!)",
                                    "badge": "Increment",
                                    "notifyType": "winner" ]
        
        let push = PFPush()
        push.setQuery(pushQuery)
        push.setData(data as [NSObject : AnyObject])
        push.sendPushInBackground()
    }
}