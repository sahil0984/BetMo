//
//  HomeViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, CreateBetViewControllerDelegate {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var feedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var viewContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sidebarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewContainerTrailingConstraint: NSLayoutConstraint!

    var homeFeedContainer: FeedViewController!
    var openBetsFeedContainer: FeedViewController!
    var myBetsFeedContainer: FeedViewController!
    var allViewControllers: [FeedViewController] = [FeedViewController]()
    var newBet: Bet?

    // Containers handler
    var activeViewController: UIViewController? {
        didSet(oldViewControllerOrNil) {
            if let oldVC = oldViewControllerOrNil {
                oldVC.willMoveToParentViewController(nil)
                oldVC.view.removeFromSuperview()
                oldVC.removeFromParentViewController()
                self.view.layoutIfNeeded()
            }
            if let newVC = activeViewController {
                self.addChildViewController(newVC)
                newVC.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                newVC.view.frame = self.viewContainer.bounds
                self.viewContainer.addSubview(newVC.view)
                newVC.didMoveToParentViewController(self)
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Create all view controllers
        homeFeedContainer = storyboard.instantiateViewControllerWithIdentifier("FeedViewController") as FeedViewController

        openBetsFeedContainer = storyboard.instantiateViewControllerWithIdentifier("FeedViewController") as FeedViewController
        openBetsFeedContainer.feedViewType = "Open Bets"

        myBetsFeedContainer = storyboard.instantiateViewControllerWithIdentifier("FeedViewController") as FeedViewController
        myBetsFeedContainer.feedViewType = "My Bets"

        // For easier access when using segmented control
        allViewControllers = [openBetsFeedContainer, homeFeedContainer, myBetsFeedContainer]
        activeViewController = homeFeedContainer

        // Do any additional setup after loading the view.
        loadUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onHamburger(sender: AnyObject) {
        if sidebarLeadingConstraint.constant == 0 {
            hideSideBar()
        } else {
            showSidebar()
        }
    }

    @IBAction func onLogout(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("userDidLogoutNotification", object: nil)
    }

    func createdBet(betCreated: Bet) {
        self.newBet = betCreated
        BetMoClient.sharedInstance.allBets.insert(betCreated, atIndex: 0)
    }

    @IBAction func onFeedChange(sender: UISegmentedControl) {
        activeViewController = allViewControllers[sender.selectedSegmentIndex]
    }
    
    //TODO: Need to figure out a better place to do this in order to slim down this controller
    func loadUserData() {
        var request = FBRequest.requestForMe()
        request.startWithCompletionHandler { (connection, result, error: NSError?) -> Void in
            if error == nil {
                println(result)
                var userData = result as NSDictionary
                var fbId = userData["id"] as String

                var currUser = PFUser.currentUser() as User
                currUser.setFbId(userData["id"] as String)
                currUser.setFirstName(userData["first_name"] as String)
                currUser.setLastName(userData["last_name"] as String)
                currUser.setEmail(userData["email"] as String)
                currUser.setProfileImageUrl("https://graph.facebook.com/\(fbId)/picture?type=large&return_ssl_resources=1" as String)
                
                var searchName = currUser.getName().lowercaseString
                currUser.setSearchName(searchName)
                
                currUser.saveInBackground()
  
            } else {
                println("Facebook request error: \(error)")
            }
        }
        
        
        // Associate the device with a user
        var installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.saveInBackground()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var createBetViewController = segue.destinationViewController as CreateBetViewController
        
        createBetViewController.delegate = self
    }

    func hideSideBar() {
        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.sidebarLeadingConstraint.constant = -200
            self.viewContainerTrailingConstraint.constant = 0
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.layoutIfNeeded()
        })
    }
    
    func showSidebar() {
        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.sidebarLeadingConstraint.constant = 0
            self.viewContainerTrailingConstraint.constant = -200
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.layoutIfNeeded()
        })
    }

}
