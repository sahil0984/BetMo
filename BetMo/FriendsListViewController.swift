//
//  FriendListViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/10/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol FriendsListViewControllerDelegate {
    func friendSelected(selectedFriend : User) -> Void
    func friendListEditChanged(state: Int) -> Void
}

class FriendsListViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var friendNameTextField: UITextField!
    @IBOutlet weak var friendsListTableView: UITableView!
    
    var delegate: FriendsListViewControllerDelegate?
    var friendsList: [User] = []
    
    var fbAllFriendIds: [String] = []
    
    var openBetFriend = User()

    var newBet = Bet()
    
    var firstTimeEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        friendsListTableView.dataSource = self
        friendsListTableView.delegate = self
        friendsListTableView.rowHeight = UITableViewAutomaticDimension
        friendsListTableView.tableFooterView = UIView(frame: CGRectZero)
        
        openBetFriend.setFirstName("Open Bet")
        openBetFriend.setLastName("")
        
        
        
        // Issue a Facebook Graph API request to get your user's friend list
        FBRequestConnection.startForMyFriendsWithCompletionHandler({ (connection, result, error: NSError!) -> Void in
            if error == nil {
                //println(result)
                // result will contain an array with your user's friends in the "data" key
                var friendObjects = result["data"] as [NSDictionary]
                
                // Create a list of friends' Facebook IDs
                for friendObject in friendObjects {
                    self.fbAllFriendIds.append(friendObject["id"] as NSString)
                    //var tt = friendObject["id"] as NSString
                    //println("fid = \(tt)")
                }
                
                self.updateFriendsList()
                
                println("\(friendObjects.count)")
            } else {
                println("Error requesting friends list form facebook")
                println("\(error)")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onEditingChanged(sender: AnyObject) {
        println("Edit changed")
        friendsListTableView.hidden = false
        updateFriendsList()
        
        if firstTimeEdit == true {
            delegate?.friendListEditChanged(0)
            firstTimeEdit = false
        } else {
            
        }
        
        
        
    }
    
    
    func updateFriendsList() {
        var friendsQuery = PFQuery(className: "_User")
        friendsQuery.whereKey("fbId", containedIn: fbAllFriendIds)
        
        friendsQuery.whereKey("searchName", hasPrefix: friendNameTextField.text.lowercaseString)
        friendsQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var friends = objects as [User]
                if friends.count == 0 {
                    println("Not Found: \(self.friendNameTextField.text)")
                    self.friendsList = []
                } else {
                    println("Found: \(self.friendNameTextField.text)")
                    self.friendsList = friends
                }
                self.friendsList.insert(self.openBetFriend, atIndex: 0)
                self.friendsListTableView.reloadData()
            } else {
                println("Error finding")
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("friendCell") as FriendTableViewCell
        
        if indexPath.row == 0 {
            cell.nameLabel.text = "Open Bet"
            cell.profileImageView.image = UIImage(named: "empty_user")
        } else {
            cell.friend = friendsList[indexPath.row]
        }
        
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        view.endEditing(true)
        
        friendNameTextField.text = friendsList[indexPath.row].getName()
        friendsListTableView.hidden = true
        //hideFriendsListTable()
        
//        if indexPath.row == 0 {
//            //dont set selected friend
//            //var tmpUser = User()
//            //self.delegate?.friendSelected(nil)
//        } else {
//            self.delegate?.friendSelected(self.friendsList[indexPath.row])
//        }
        self.delegate?.friendSelected(self.friendsList[indexPath.row])
        
        
        firstTimeEdit = true
    }
    
    func hideFriendsListTable() {
        
        println("start: \(friendsListTableView.frame.origin.y)")
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.friendsListTableView.frame.origin.y = self.friendsListTableView.frame.origin.y - self.friendsListTableView.frame.height
            println("start: \(self.friendsListTableView.frame.origin.y)")
        }) { (finished) -> Void in
            println("end: \(self.friendsListTableView.frame.origin.y)")
            
        }
        
    }
    

}
