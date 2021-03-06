//
//  User.swift
//  BetMo
//
//  Created by Sahil Arora on 10/9/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class User : PFUser {
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override init() {
        super.init()
        //Nil User object
    }

    // Getters and Setters for all User properties

    func getFirstName() -> String {
        return self["firstName"] as! String
    }
    
    func setFirstName(firstName: String) {
        self["firstName"] = firstName
    }

    func getLastName() -> String {
        return self["lastName"] as! String
    }
    
    func setLastName(lastName: String) {
        self["lastName"] = lastName
    }

    func getName() -> String {
        return (getFirstName() + " " + getLastName())
    }
    
    func getUserEmail() -> String? {
        return self["email"] as? String
    }

    func setUserEmail(email: String) {
        self["email"] = email
    }

    func getFbId() -> String? {
        return self["fbId"] as? String
    }
    
    func setFbId(fbId: String) {
        self["fbId"] = fbId
    }

    func getProfileImageUrl() -> String? {
        return self["profileImageUrl"] as? String
    }

    func setProfileImageUrl(profileImageUrl: String) {
        self["profileImageUrl"] = profileImageUrl
    }

    //Only getter for banner
    func getBannerImageUrl() -> String? {
        //return "https://graph.facebook.com/\(self.getFbId()!)?fields=cover&access_token=\(PFFacebookUtils.session().accessTokenData)"
        return "https://graph.facebook.com/\(self.getFbId()!)?fields=cover&access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
    }
    
    func getSearchName() -> String? {
        return self["searchName"] as? String
    }
    
    func setSearchName(searchName: String) {
        self["searchName"] = searchName
    }
    
    func getLastOpenBetAt() -> NSDate? {
        return self["lastOpenBetAt"] as? NSDate
    }
    
    func setLastOpenBetAt(lastOpenBetAt: NSDate) {
        self["lastOpenBetAt"] = lastOpenBetAt
    }
    
}