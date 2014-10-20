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
}

class FriendsListViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var friendNameTextField: UITextField!
    @IBOutlet weak var friendsListTableView: UITableView!
    
    var delegate: FriendsListViewControllerDelegate?
    var friendsList: [User] = []
    
    var fbAllFriendIds: [String] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        friendsListTableView.dataSource = self
        friendsListTableView.delegate = self
        friendsListTableView.rowHeight = UITableViewAutomaticDimension
        
        
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
        updateFriendsList()
    }
    
    @IBAction func onEditTextTouchDown(sender: AnyObject) {
        println("Edit text touch")
        updateFriendsList()
    }
    
    
    func updateFriendsList() {
        var friendsQuery = PFQuery(className: "_User")
        friendsQuery.whereKey("fbId", containedIn: fbAllFriendIds)
        
        friendsQuery.whereKey("searchName", hasPrefix: friendNameTextField.text)
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
            cell.friend = friendsList[indexPath.row]
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        self.dismissViewControllerAnimated(false) { () -> Void in
            println("")
            self.delegate?.friendSelected(self.friendsList[indexPath.row])
        }
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
