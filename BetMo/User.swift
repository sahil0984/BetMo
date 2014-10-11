//
//  User.swift
//  BetMo
//
//  Created by Sahil Arora on 10/9/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class User : PFUser, PFSubclassing {
    
    override class func load() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    override init() {
        super.init()
        //Nil User object
    }


/////////NOTE: We might not need to add any getters and setters as Parse adds them automatically when you set key
/////////      But then we still want to add them for other purposes
    
//This is the general format for how to add getters/setters
//    //Getters
//    func getFirstName() -> String {
//        return self["firstName"] as String
//    }
//    func getLastName() -> String {
//        return self["lastName"] as String
//    }
    
}