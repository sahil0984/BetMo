//
//  BetsFeedViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class BetsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profileHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var betsFeedTableView: UITableView!

    let feedTab = "feed"
    let requestTab = "requests"
    let profileTab = "profile"
    // Default is the feeds tab
    var feedViewType: String = "feed"

    var bets = [Bet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        betsFeedTableView.dataSource = self
        betsFeedTableView.delegate = self
        betsFeedTableView.rowHeight = UITableViewAutomaticDimension
        profileHeaderHeightConstraint.constant = 0
        if feedViewType == profileTab {
            profileHeaderHeightConstraint.constant = 250
            self.bets = BetMoClient.sharedInstance.profileBets
            betsFeedTableView.reloadData()
        } else if feedViewType == requestTab {
            self.bets = BetMoClient.sharedInstance.getAllRequestedBets()
            betsFeedTableView.reloadData()
        } else {
            MBProgressHUD.showHUDAddedTo(betsFeedTableView, animated: true)
            BetMoClient.sharedInstance.getAllBets({ (bets, error) -> () in
                if error != nil {
                    println("Error while getting all bets")
                } else {
                    self.bets = BetMoClient.sharedInstance.feedBets
                    self.betsFeedTableView.reloadData()
                    MBProgressHUD.hideHUDForView(self.betsFeedTableView, animated: true)
                }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if feedViewType == profileTab {
            self.bets = BetMoClient.sharedInstance.profileBets
        } else if feedViewType == requestTab {
            self.bets = BetMoClient.sharedInstance.getAllRequestedBets()
        } else if feedViewType == feedTab {
            self.bets = BetMoClient.sharedInstance.feedBets
        }
        betsFeedTableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("betFeedCell") as BetsFeedTableViewCell
        
        cell.bet = bets[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
