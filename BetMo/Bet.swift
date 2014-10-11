//
//  Bet.swift
//  BetMo
//
//  Created by Sahil Arora on 10/9/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class Bet : PFObject, PFSubclassing {

    func getOwner() -> User {
        return self["owner"] as User
    }
    
    func setOwner(owner: User) {
        self["owner"] = owner
    }
    
    func getDescription() -> String {
        return self["description"] as String
    }
    
    func setDescription(description: String) {
        self["description"] = description
    }

    func getAmount() -> String {
        return self["amount"] as String
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

    func getWinner() -> User {
        return self["winner"] as User
    }

    func setWinner(winner: User) {
        self["winner"] = winner
    }

    func getOppenent() -> User {
        return self["opponent"] as User
    }
    
    func setOpponent(opponent: User) {
        self["opponent"] = opponent
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