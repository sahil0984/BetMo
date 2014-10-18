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
        return self.objectId as String
    }
    
    func getOwner() -> User {
        return self["owner"] as User
    }
    
    func setOwner(owner: User) {
        self["owner"] = owner
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
        return self["isAccepted"] as Bool
    }

    func setIsAccepted(isAccepted: Bool) {
        self["isAccepted"] = isAccepted
    }

    func getWinner() -> User? {
        return self["winner"] as? User
    }

    func setWinner(winner: User) {
        self["winner"] = winner
    }

    func getOppenent() -> User? {
        return self["opponent"] as? User
    }
    
    func setOpponent(opponent: User) {
        self["opponent"] = opponent
    }

    func getCreatedAt() -> String? {
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
        var currentUser = PFUser.currentUser() as User
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                println("Successfully created bet");
                
                var returnedObjectId = self.getObjectId()
                
                //Create a channel for push notifications in current installation
                var currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject("ch_\(returnedObjectId)", forKey: "channels")
                currentInstallation.saveInBackground()
                
                
                if let opponent = self.getOppenent() {
                    //Find opponent
                    var opponentQuery = User.query()
                    opponentQuery.whereKey("fbId", equalTo: opponent.getFbId())
                    //Find devices associated with the opponent
                    var pushQuery = PFInstallation.query()
                    pushQuery.whereKey("user", matchesQuery: opponentQuery)
                    //Send push notification to opponent
                    var push = PFPush()
                    push.setQuery(pushQuery)
                    push.setMessage("\(currentUser.getName()) has challenged you to a bet.")
                    push.sendPushInBackground()
                }
                
            } else {
                println("Failed creating the bet");
                println("\(error!)")
            }
        }
    }
    
    func accept() {
        var currentUser = PFUser.currentUser() as User
        setOpponent(currentUser)
        setIsAccepted(true)
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                println("Successfully accepted bet");
                
                //Create a channel for push notifications in current installation
                var currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject("ch_\(self.getObjectId())", forKey: "channels")
                currentInstallation.saveInBackground()
                
                
                //Find owner
                var ownerQuery = User.query()
                ownerQuery.whereKey("fbId", equalTo: self.getOwner().getFbId())
                //Find devices associated with the owner
                var pushQuery = PFInstallation.query()
                pushQuery.whereKey("user", matchesQuery: ownerQuery)
                //Send push notification to opponent
                var push = PFPush()
                push.setQuery(pushQuery)
                push.setMessage("\(currentUser.getName()) has accepted your bet.")
                push.sendPushInBackground()
                
                
            } else {
                println("Failed to accept bet");
                println("\(error!)")
            }
        }
    }

    // For now remove the current user as the opponent when they reject the bet
    func reject() {
        var currentUser = PFUser.currentUser() as User
        self["opponent"] = nil
        setIsAccepted(false)
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                println("Successfully rejected bet");
            } else {
                println("Failed to reject bet");
                println("\(error!)")
            }
        }
    }

    func cancel() {
        self.deleteInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                println("Successfully deleted bet");
                
                //Delete a channel for push notifications in current installation
                var currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.removeObject("ch_\(self.getObjectId())", forKey: "channels")
                currentInstallation.saveInBackground()

            } else {
                println("Failed to delete bet");
                println("\(error!)")
            }
        }
    }
    
    func lost() {
        var currentUser = PFUser.currentUser() as User
        if currentUser.getFbId() == self.getOwner().getFbId() {
            self["winner"] = self.getOppenent()!
        } else {
            self["winner"] = self.getOwner()
        }

        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                println("Successfully saved that I lost");
            } else {
                println("Failed to save that I lost");
                println("\(error!)")
            }
        }
    }

    func won() {
        var currentUser = PFUser.currentUser() as User
        self["winner"] = currentUser
        self.saveInBackgroundWithBlock { (isSaved: Bool, error: NSError?) -> Void in
            if isSaved {
                println("Successfully saved that I won");
            } else {
                println("Failed to save that I won");
                println("\(error!)")
            }
        }
    }

    override class func load() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String! {
        return "Bet"
    }
    
    
    //Getters
    
    
    //Setters
    
    
}