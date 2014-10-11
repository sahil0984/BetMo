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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        friendsListTableView.dataSource = self
        friendsListTableView.delegate = self
        friendsListTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onEditingChanged(sender: AnyObject) {
        println("Edit changed")
        if friendNameTextField.text == "" {
            self.friendsList = []
            self.friendsListTableView.reloadData()
        } else {
            // Issue a Facebook Graph API request to get your user's friend list
            FBRequestConnection.startForMyFriendsWithCompletionHandler({ (connection, result, error: NSError!) -> Void in
                if error == nil {
                    //println(result)
                    // result will contain an array with your user's friends in the "data" key
                    var friendObjects = result["data"] as [NSDictionary]
                    var friendIds: [String] = []
                    
                    // Create a list of friends' Facebook IDs
                    for friendObject in friendObjects {
                        friendIds.append(friendObject["id"] as NSString)
                        //var tt = friendObject["id"] as NSString
                        //println("fid = \(tt)")
                    }
                    
                    
                    
                    println("\(friendObjects.count)")
                } else {
                    println("Error requesting friends list form facebook")
                    println("\(error)")
                }
            })
            
            
            
            
            
            
            
//            // Issue a Facebook Graph API request to get your user's friend list
//            [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                if (!error) {
//                // result will contain an array with your user's friends in the "data" key
//                NSArray *friendObjects = [result objectForKey:@"data"];
//                NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
//                // Create a list of friends' Facebook IDs
//                for (NSDictionary *friendObject in friendObjects) {
//                [friendIds addObject:[friendObject objectForKey:@"id"]];
//                }
//                
//                // Construct a PFUser query that will find friends whose facebook ids
//                // are contained in the current user's friend list.
//                PFQuery *friendQuery = [PFUser query];
//                [friendQuery whereKey:@"fbId" containedIn:friendIds];
//                
//                // findObjects will return a list of PFUsers that are friends
//                // with the current user
//                NSArray *friendUsers = [friendQuery findObjects];
//                }
//                }];
            
            
            
            
            
        
//            //Search Parse for facebook friends
//            var friendsQuery = PFQuery(className: "_User")
//            friendsQuery.whereKey("searchName", hasPrefix: friendNameTextField.text)
//            friendsQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
//                if error == nil {
//                    var friends = objects as [User]
//                    if friends.count == 0 {
//                        println("Not Found: \(self.friendNameTextField.text)")
//                        self.friendsList = []
//                    } else {
//                        println("Found: \(self.friendNameTextField.text)")
//                        self.friendsList = friends
//                    }
//                    self.friendsListTableView.reloadData()
//                } else {
//                    println("Error finding")
//                }
//            }
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
        
        delegate?.friendSelected(friendsList[indexPath.row])
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
