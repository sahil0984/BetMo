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

    @IBOutlet weak var betsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        betsTableView.delegate = self
        betsTableView.dataSource = self
        BetMoClient.sharedInstance.getAllBets({ (bets, error) -> () in
            if error != nil {
                println("Error while getting all bets")
            } else {
                self.bets = BetMoClient.sharedInstance.betsCompleted
                self.betsTableView.reloadData()
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
