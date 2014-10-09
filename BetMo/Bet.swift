//
//  Bet.swift
//  BetMo
//
//  Created by Sahil Arora on 10/9/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class Bet : PFObject, PFSubclassing {
    
    override class func load() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String! {
        return "User"
    }
    
    
    //Getters
    
    
    //Setters
    
    
}