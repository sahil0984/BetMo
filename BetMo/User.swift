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

    // Getters and Setters for all User properties

    func getFirstName() -> String {
        return self["firstName"] as String
    }
    
    func setFirstName(firstName: String) {
        self["firstName"] = firstName
    }

    func getLastName() -> String {
        return self["lastName"] as String
    }
    
    func setLastName(lastName: String) {
        self["lastName"] = lastName
    }

    func getName() -> String {
        return (getFirstName() + " " + getLastName())
    }
    
    func getEmail() -> String {
        return self["email"] as String
    }

    func setEmail(email: String) {
        self["email"] = email
    }

    func getFbId() -> String {
        return self["fbId"] as String
    }
    
    func setFbId(fbId: String) {
        self["fbId"] = fbId
    }

    func getProfileImageUrl() -> String {
        return self["profileImageUrl"] as String
    }

    func setProfileImageUrl(profileImageUrl: String) {
        self["profileImageUrl"] = profileImageUrl
    }
    
}