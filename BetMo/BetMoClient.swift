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

    func getAllBets(completion: (bets: [Bet]?, error: NSError?) -> ()) {
        var betsQuery = PFQuery(className: "Bet")
        betsQuery.includeKey("owner")
        betsQuery.includeKey("opponent")
        betsQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var bets = objects as [Bet]
                completion(bets: bets, error: nil)
            } else {
                completion(bets: nil, error: error)
            }
        }
    }

    func getAllBetsForUser(userId: String?, completion: (bets: [Bet], error: NSError?) -> ()) {

    }
    
}