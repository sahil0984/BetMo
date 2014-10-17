//
//  FeedViewController.swift
//  BetMo
//
//  Created by Sahil Amoli on 10/10/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BetDetailViewControllerDelegate {
    
    let feedTab = "feed"
    let requestTab = "requests"
    let profileTab = "profile"

    var bets: [Bet] = [Bet]()
    var selectedBet: Bet = Bet()
    // Default is the feeds tab
    var feedViewType: String = "feed"

    @IBOutlet weak var betsTableView: UITableView!
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        betsTableView.delegate = self
        betsTableView.dataSource = self
        if feedViewType == profileTab {
            self.bets = BetMoClient.sharedInstance.profileBets
            betsTableView.reloadData()
        } else if feedViewType == requestTab {
            self.bets = BetMoClient.sharedInstance.getAllRequestedBets()
            betsTableView.reloadData()
        } else {
            MBProgressHUD.showHUDAddedTo(betsTableView, animated: true)
            betsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            BetMoClient.sharedInstance.getAllBets({ (bets, error) -> () in
                if error != nil {
                    println("Error while getting all bets")
                } else {
                    self.bets = BetMoClient.sharedInstance.feedBets
                    self.betsTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                    self.betsTableView.reloadData()
                    MBProgressHUD.hideHUDForView(self.betsTableView, animated: true)
                }
                
            })
        }
        betsTableView.rowHeight = UITableViewAutomaticDimension
        addRefreshControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // @TODO HACK TO REMOVE CONSTRAINT WARNINGS
    override func viewWillDisappear(animated: Bool) {
        betsTableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        if feedViewType == profileTab {
            self.bets = BetMoClient.sharedInstance.profileBets
        } else if feedViewType == requestTab {
            self.bets = BetMoClient.sharedInstance.getAllRequestedBets()
        } else if feedViewType == feedTab {
            self.bets = BetMoClient.sharedInstance.feedBets
        }
        betsTableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bets.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = betsTableView.dequeueReusableCellWithIdentifier("BetCell") as BetCell
        cell.bet = bets[indexPath.row] as Bet
        
        CellAnimator.animateCellAppear(cell)
        
        return cell
    }

    // This is needed for the swiping cell ability
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var bet = bets[indexPath.row] as Bet
        var currentUser = PFUser.currentUser() as User
        var owner = bet.getOwner() as User
        var opponent = bet.getOppenent()
        var winner = bet.getWinner()
        var button1: UITableViewRowAction!
        var button2: UITableViewRowAction!

        if owner.getFbId() == currentUser.getFbId() {
            if opponent == nil || bet.getIsAccepted() == false {
                button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Cancel Bet", handler:{action, indexpath in
                    println("Bet Cancelled");
                    bet.cancel()
                    self.bets.removeAtIndex(indexPath.row)
                    self.betsTableView.reloadData()
                });
                return [button1]
            } else if opponent != nil && bet.getIsAccepted() == true && winner == nil {
                button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Won", handler:{action, indexpath in
                    println("I won the bet")
                    bet.won()
                    self.betsTableView.reloadData()
                });
                button1.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
                
                button2 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Lost", handler:{action, indexpath in
                    println("I lost the bet");
                    bet.lost()
                    self.betsTableView.reloadData()
                });
                
                return [button1, button2]
            }
        }

        if opponent != nil {
            if opponent!.getFbId() == currentUser.getFbId() && bet.getIsAccepted() == false {
                button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Accept", handler:{action, indexpath in
                    println("Accepted Bet Request");
                    bet.accept()
                    self.betsTableView.reloadData()
                });
                button1.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);

                button2 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Reject", handler:{action, indexpath in
                    println("Rejected Bet Request");
                    bet.reject()
                    self.bets.removeAtIndex(indexPath.row)
                    self.betsTableView.reloadData()
                });
                
                return [button1, button2]
            } else if opponent!.getFbId() == currentUser.getFbId() && bet.getIsAccepted() == true && winner == nil {
                button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Won", handler:{action, indexpath in
                    println("I won the bet");
                    bet.won()
                    self.betsTableView.reloadData()
                });
                button1.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
                
                button2 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Lost", handler:{action, indexpath in
                    println("I lost the bet");
                    bet.lost()
                    self.betsTableView.reloadData()
                });

                return [button1, button2]
            }
        }

        if opponent == nil {
            button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Accept Bet", handler:{action, indexpath in
                println("Accepted Open Bet");
                bet.accept()
                self.bets.removeAtIndex(indexPath.row)
                self.betsTableView.reloadData()
            });
            button1.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
            return [button1]
        }

        button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "More", handler:{action, indexpath in
            // Invoke details view segue
            println("More Info");
            self.selectedBet = bet
            self.performSegueWithIdentifier("betDetail", sender: "More")
        });
        button1.backgroundColor = UIColor.grayColor()
        return [button1]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //TipInCellAnimator.animateCellFlip(tableView.cellForRowAtIndexPath(indexPath)!)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "betDetail" {
            var betDetailViewController = segue.destinationViewController as BetDetailViewController
            
            if (sender as? String) != "More" {
                var selectedRow = self.betsTableView.indexPathForSelectedRow()?.row
                self.selectedBet = self.bets[selectedRow!]
            }
            betDetailViewController.currBet = self.selectedBet
            
            betDetailViewController.delegate = self
        }
    }
    
    func acceptedBet(betAccepted: Bet) {
        for (index,bet) in enumerate(bets) {
            if bet.getObjectId() == betAccepted.getObjectId() {
                bets.removeAtIndex(index)
                BetMoClient.sharedInstance.openBets = bets
                println("removed : \(index)")
                betsTableView.reloadData()
                break
            }
        }
    }

    func refresh(sender: AnyObject) {
        BetMoClient.sharedInstance.getAllBets({ (bets, error) -> () in
            if error != nil {
                println("Error while getting all bets")
            } else {
                if self.feedViewType == self.profileTab {
                    self.bets = BetMoClient.sharedInstance.profileBets
                } else if self.feedViewType == self.requestTab {
                    self.bets = BetMoClient.sharedInstance.getAllRequestedBets()
                } else if self.feedViewType == self.feedTab {
                    self.bets = BetMoClient.sharedInstance.feedBets
                }
                self.betsTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }

    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        // Add target for refresh
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)

        // Add the refresh control to the table view
        betsTableView.insertSubview(self.refreshControl, atIndex: 0)
    }

}
