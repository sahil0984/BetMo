//
//  FeedViewController.swift
//  BetMo
//
//  Created by Sahil Amoli on 10/10/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var bets: [Bet] = [Bet]()
    var selectedBet: Bet = Bet()
    var feedViewType: String = "Home"

    @IBOutlet weak var betsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        betsTableView.delegate = self
        betsTableView.dataSource = self
        if feedViewType == "My Bets" {
            self.bets = BetMoClient.sharedInstance.myBets
            betsTableView.reloadData()
        } else if feedViewType == "Open Bets" {
            self.bets = BetMoClient.sharedInstance.openBets
            betsTableView.reloadData()
        } else {
            BetMoClient.sharedInstance.getAllBets({ (bets, error) -> () in
                if error != nil {
                    println("Error while getting all bets")
                } else {
                    self.bets = BetMoClient.sharedInstance.betsCompleted
                    self.betsTableView.reloadData()
                }
                
            })
        }
        betsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if feedViewType == "My Bets" {
            self.bets = BetMoClient.sharedInstance.myBets
        } else if feedViewType == "Open Bets" {
            self.bets = BetMoClient.sharedInstance.openBets
        } else if feedViewType == "Home" {
            self.bets = BetMoClient.sharedInstance.betsCompleted
        }
        betsTableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bets.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = betsTableView.dequeueReusableCellWithIdentifier("BetCell") as BetCell
        cell.bet = bets[indexPath.row] as Bet
        return cell
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        println("hi1")
    }

//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: false)
//        println("selectedBet1: \(self.selectedBet)")
//        self.selectedBet = bets[indexPath.row]
//    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("hi2")
    }

    // This is needed for the swiping cell ability
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var bet = bets[indexPath.row] as Bet
        var currentUser = PFUser.currentUser() as User
        var owner = bet.getOwner() as User
        var opponent = bet.getOppenent()
        var button1: UITableViewRowAction!
        var button2: UITableViewRowAction!

        if owner.getFbId() == currentUser.getFbId() {
            if opponent == nil || bet.getIsAccepted() == false {
                button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Cancel Bet", handler:{action, indexpath in
                    println("Bet Cancelled");
                });
                return [button1]
            }
        }

        if opponent != nil {
            if opponent!.getFbId() == currentUser.getFbId() && bet.getIsAccepted() == false {
                button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Accept", handler:{action, indexpath in
                    println("Accepted Bet Request");
                });
                button1.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);

                button2 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Reject", handler:{action, indexpath in
                    println("Rejected Bet Request");
                });

                return [button1, button2]
            }
        }

        if opponent == nil {
            button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Accept Bet", handler:{action, indexpath in
                println("Accepted Open Bet");
            });
            button1.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
            return [button1]
        }

        return []
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "betDetail" {
            var betDetailViewController = segue.destinationViewController as BetDetailViewController
            
            //var tmp = self.selectedBet
            //var tmp1 = tmp.getOwner().getName()
            println("selectedBet2: \(self.selectedBet)")
            betDetailViewController.currBet = self.selectedBet
            
            //betDetailViewController.delegate = self
        }
    }


}
