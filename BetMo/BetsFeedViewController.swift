//
//  BetsFeedViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class BetsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomCellNibDelegate {

    @IBOutlet weak var profileHeaderView: ProfileHeaderView!
    @IBOutlet weak var profileHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileHeaderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var betsFeedTableView: UITableView!

    var refreshControl: UIRefreshControl!

    let feedTab = "feed"
    let requestTab = "requests"
    let profileTab = "profile"
    // Default is the feeds tab
    var feedViewType: String = "feed"

    var bets = [Bet]()
    var isDragging = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        betsFeedTableView.dataSource = self
        betsFeedTableView.delegate = self
        betsFeedTableView.rowHeight = UITableViewAutomaticDimension
        betsFeedTableView.estimatedRowHeight = 200
        profileHeaderTopConstraint.constant = -192
        if feedViewType == profileTab {
            profileHeaderTopConstraint.constant = 0
            self.bets = BetMoClient.sharedInstance.profileBets
            betsFeedTableView.reloadData()
        } else if feedViewType == requestTab {
            self.bets = BetMoClient.sharedInstance.getAllRequestedBets()
            betsFeedTableView.reloadData()
        } else {
            MBProgressHUD.showHUDAddedTo(betsFeedTableView, animated: true)
            BetMoClient.sharedInstance.getAllBets({ (bets, error) -> () in
                if error != nil {
                    print("Error while getting all bets")
                } else {
                    self.bets = BetMoClient.sharedInstance.feedBets
                    self.betsFeedTableView.reloadData()
                    MBProgressHUD.hideHUDForView(self.betsFeedTableView, animated: true)
                }
            })
        }
        addRefreshControl()
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

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if feedViewType == profileTab {
            let offsetY = scrollView.contentOffset.y
            let isBottomBounce = (offsetY >= (self.betsFeedTableView.contentSize.height - self.betsFeedTableView.bounds.size.height))

            if offsetY > 0 && offsetY < 111 && isBottomBounce == false {
                profileHeaderTopConstraint.constant = -1*scrollView.contentOffset.y
                // Remove the blur
                self.profileHeaderView.visualEffectView.alpha = offsetY/300
            } else if offsetY < 111 && profileHeaderTopConstraint.constant != 0 {
                // TOP BOUNCE CASE
                profileHeaderTopConstraint.constant = 0
                // Remove the blur
                self.profileHeaderView.visualEffectView.alpha = offsetY/300
            } else if offsetY > 110 && profileHeaderTopConstraint.constant != -110 {
                profileHeaderTopConstraint.constant = -110
            } else if offsetY <= 0 {
                // Zoom header image!
                let scale = 1 + (-1 * offsetY/150)
                profileHeaderView.bannerImageView.transform = CGAffineTransformMakeScale(scale, scale)
//                profileHeaderView.proflieImageView.layer.transform = CATransform3DRotate(profileHeaderView.proflieImageView.layer.transform, -1*offsetY, 1, 0, 0)
            }
            // Increase the alpha for visual effect view
            if offsetY > 110 && offsetY/300 < 1.0 {
                self.profileHeaderView.visualEffectView.alpha = offsetY/300
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("betFeedCell") as! BetsFeedTableViewCell
        
        if feedViewType == requestTab || feedViewType == profileTab {
            cell.customBetCellView.isRequest = true
        }

        cell.bet = bets[indexPath.row]
        cell.customBetCellView.rowIndex = indexPath.row
        cell.customBetCellView.delegate = self

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    func betAccepted(acceptedBet: Bet) {
        print("bet accpeted: \(acceptedBet.getObjectId())")
    }
    
    func betRejected(customCellNib: CustomCellNib, rejectedBet: Bet) {
        print("bet rejected: \(rejectedBet.getObjectId())")
        
        let rowIndex = customCellNib.rowIndex
        if self.bets.count > rowIndex && self.bets[rowIndex] == rejectedBet {
            self.bets.removeAtIndex(rowIndex)
            self.betsFeedTableView.reloadData()
        }
    }
    
    func betCancelled(customCellNib: CustomCellNib, cancelledBet: Bet) {
        let rowIndex = customCellNib.rowIndex
        if self.bets.count > rowIndex && self.bets[rowIndex] == cancelledBet {
            self.bets.removeAtIndex(rowIndex)
            self.betsFeedTableView.reloadData()
        }
    }

    func winnerChosen(customCellNib: CustomCellNib, bet: Bet) {
        let rowIndex = customCellNib.rowIndex
        if self.bets.count > rowIndex {
            // replace with new info
            self.bets[rowIndex] = bet
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        // Add target for refresh
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Add the refresh control to the table view
        betsFeedTableView.insertSubview(self.refreshControl, atIndex: 0)
    }

    func refresh(sender: AnyObject) {
        BetMoClient.sharedInstance.getAllBets({ (bets, error) -> () in
            if error != nil {
                print("Error while getting all bets")
            } else {
                if self.feedViewType == self.profileTab {
                    self.bets = BetMoClient.sharedInstance.profileBets
                } else if self.feedViewType == self.requestTab {
                    self.bets = BetMoClient.sharedInstance.getAllRequestedBets()
                } else if self.feedViewType == self.feedTab {
                    self.bets = BetMoClient.sharedInstance.feedBets
                }
                self.betsFeedTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
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
