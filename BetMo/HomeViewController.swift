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
    @IBOutlet weak var viewContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sidebarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var requestsButton: UIButton!
    @IBOutlet weak var feedButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!

    var homeFeedContainer: BetsFeedViewController!
    var openBetsFeedContainer: BetsFeedViewController!
    var myBetsFeedContainer: BetsFeedViewController!
    var allViewControllers: [BetsFeedViewController] = [BetsFeedViewController]()
    var newBet: Bet?

    let feedTab = "feed"
    let requestTab = "requests"
    let profileTab = "profile"

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
        homeFeedContainer = storyboard.instantiateViewControllerWithIdentifier("BetsFeedViewController") as BetsFeedViewController

        openBetsFeedContainer = storyboard.instantiateViewControllerWithIdentifier("BetsFeedViewController") as BetsFeedViewController
        openBetsFeedContainer.feedViewType = requestTab

        myBetsFeedContainer = storyboard.instantiateViewControllerWithIdentifier("BetsFeedViewController") as BetsFeedViewController
        myBetsFeedContainer.feedViewType = profileTab

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

    @IBAction func onTabBarButton(button: UIButton) {
        if button == profileButton {
            if activeViewController != allViewControllers[2] {
                activeViewController = allViewControllers[2]
            }
        } else if button == requestsButton {
            if activeViewController != allViewControllers[0] {
                activeViewController = allViewControllers[0]
            }
        } else if button == feedButton {
            if activeViewController != allViewControllers[1] {
                activeViewController = allViewControllers[1]
            }
        }
    }

    @IBAction func onLogout(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("userDidLogoutNotification", object: nil)
    }

    func createdBet(betCreated: Bet) {
        self.newBet = betCreated
        BetMoClient.sharedInstance.allBets.insert(betCreated, atIndex: 0)
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
                
                println(currUser)
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

}
