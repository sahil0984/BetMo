//
//  HomeViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, NewBetViewControllerDelegate {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sidebarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var requestsButton: UIButton!
    @IBOutlet weak var feedButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var requestButtonContainerView: UIView!
    @IBOutlet weak var homeButtonContainerView: UIView!
    @IBOutlet weak var profileButtonContainerView: UIView!
    @IBOutlet weak var discoverButtonContainerView: UIView!

    var tabSelectionColor = UIColor.blackColor()
    var tabDefaultColor: UIColor!
    var homeFeedContainer: BetsFeedViewController!
    var openBetsFeedContainer: BetsFeedViewController!
    var myBetsFeedContainer: BetsFeedViewController!
    var discoverViewController: DiscoverViewController!

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
                newVC.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                newVC.view.frame = self.viewContainer.bounds
                self.viewContainer.addSubview(newVC.view)
                newVC.didMoveToParentViewController(self)
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Create all view controllers
        homeFeedContainer = storyboard.instantiateViewControllerWithIdentifier("BetsFeedViewController") as! BetsFeedViewController

        openBetsFeedContainer = storyboard.instantiateViewControllerWithIdentifier("BetsFeedViewController") as! BetsFeedViewController
        openBetsFeedContainer.feedViewType = requestTab

        myBetsFeedContainer = storyboard.instantiateViewControllerWithIdentifier("BetsFeedViewController") as! BetsFeedViewController
        myBetsFeedContainer.feedViewType = profileTab

        discoverViewController = storyboard.instantiateViewControllerWithIdentifier("DiscoverViewController") as! DiscoverViewController

        // For easier access when using segmented control
        allViewControllers = [openBetsFeedContainer, homeFeedContainer, myBetsFeedContainer]
        activeViewController = homeFeedContainer

        tabDefaultColor = homeButtonContainerView.backgroundColor
        homeButtonContainerView.backgroundColor = tabSelectionColor
        // Do any additional setup after loading the view.
        loadUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onNewBet(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("NewBet", sender: self)
    }

    @IBAction func onRequestTab(sender: UITapGestureRecognizer) {
        if activeViewController != allViewControllers[0] {
            resetTabBarSelection()
            activeViewController = allViewControllers[0]
            requestButtonContainerView.backgroundColor = tabSelectionColor
        }
    }

    @IBAction func onHomeTab(sender: AnyObject) {
        if activeViewController != allViewControllers[1] {
            resetTabBarSelection()
            activeViewController = allViewControllers[1]
            homeButtonContainerView.backgroundColor = tabSelectionColor
        }
    }

    @IBAction func onDiscoverTab(sender: UITapGestureRecognizer) {
        if activeViewController != discoverViewController {
            resetTabBarSelection()
            activeViewController = discoverViewController
            discoverButtonContainerView.backgroundColor = tabSelectionColor
        }
    }

    @IBAction func onProfileTab(sender: UITapGestureRecognizer) {
        if activeViewController != allViewControllers[2] {
            resetTabBarSelection()
            activeViewController = allViewControllers[2]
            profileButtonContainerView.backgroundColor = tabSelectionColor
        }
    }

    func resetTabBarSelection() {
        profileButtonContainerView.backgroundColor = tabDefaultColor
        homeButtonContainerView.backgroundColor = tabDefaultColor
        requestButtonContainerView.backgroundColor = tabDefaultColor
        discoverButtonContainerView.backgroundColor = tabDefaultColor
    }

    @IBAction func onLogout(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("userDidLogoutNotification", object: nil)
    }
    
    
    func newBetCreated(newBet: Bet) {
        self.newBet = newBet
        BetMoClient.sharedInstance.allBets.insert(newBet, atIndex: 0)
    }
    
    //TODO: Need to figure out a better place to do this in order to slim down this controller
    func loadUserData() {
        //let request = FBRequest.requestForMe()
        
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: requestParameters)
        
        request.startWithCompletionHandler { (connection, result, error: NSError?) -> Void in
            if error == nil {
                print(result)
                let userData = result as! NSDictionary
                let fbId = userData["id"] as! String
                let currUser = PFUser.currentUser() as! User
                currUser.setFbId(userData["id"] as! String)
                currUser.setFirstName(userData["first_name"] as! String)
                currUser.setLastName(userData["last_name"] as! String)
                currUser.setUserEmail(userData["email"] as! String)
                currUser.setProfileImageUrl("https://graph.facebook.com/\(fbId)/picture?type=large&return_ssl_resources=1" as String)
                
                let searchName = currUser.getName().lowercaseString
                currUser.setSearchName(searchName)
                
                if currUser.getLastOpenBetAt() === nil {
                    
                    let today = NSDate()
                    let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                    let offsetComponents = NSDateComponents()
                    offsetComponents.year = 20
                    let tenYearsLater = gregorian?.dateByAddingComponents(offsetComponents, toDate: today, options: [])
                
                    print("twenty years later date: \(tenYearsLater)")
                    currUser.setLastOpenBetAt(tenYearsLater!)
                }
                
                
                currUser.saveInBackground()
                

            } else {
                print("Facebook request error: \(error)")
            }
        }
        
        
        // Associate the device with a user
        let installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.saveInBackground()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let newBetViewController = segue.destinationViewController as! NewBetViewController
        
        newBetViewController.delegate = self
    }

}
