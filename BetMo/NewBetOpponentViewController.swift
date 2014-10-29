//
//  NewBetOpponentViewController.swift
//  BetMo
//
//  Created by Sahil Arora on 10/27/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

protocol NewBetOpponentViewControllerDelegate {
    func newOpponentSubmitted(betOpponent: User)
}

class NewBetOpponentViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var friendSearchBar: UISearchBar!
    @IBOutlet weak var friendListCollectionView: UICollectionView!
    
    var delegate: NewBetOpponentViewControllerDelegate?
    
    var friendsList: [User] = []
    var fbAllFriendIds: [String] = []
    
    var openBetFriend = User()
    
    var lastSelectedCellIndexPath: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        friendListCollectionView.dataSource = self
        friendListCollectionView.delegate = self
        friendListCollectionView.backgroundColor = UIColor.whiteColor()
        //friendListCollectionView.
        
        friendSearchBar.delegate = self
        
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
    
    
    
    func updateFriendsList() {
        var friendsQuery = PFQuery(className: "_User")
        friendsQuery.whereKey("fbId", containedIn: fbAllFriendIds)
        
        friendsQuery.whereKey("searchName", hasPrefix: friendSearchBar.text.lowercaseString)
        friendsQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var friends = objects as [User]
                if friends.count == 0 {
                    println("Not Found: \(self.friendSearchBar.text)")
                    self.friendsList = []
                } else {
                    println("Found: \(self.friendSearchBar.text)")
                    self.friendsList = friends
                }
                self.friendsList.insert(self.openBetFriend, atIndex: 0)
                self.friendListCollectionView.reloadData()
            } else {
                println("Error finding")
            }
        }
    }
    
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        println("Edit changed")
        updateFriendsList()

    }
    
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendsList.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //var cell = collectionView.dequeueReusableCellWithIdentifier("FriendCell") as FriendTableViewCell
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as FriendCollectionViewCell
        
        if indexPath.row == 0 {
            cell.cellSelectOverlayView.hidden = true
            cell.friendNameLabel.text = "Open Bet"
            cell.friendImageView.image = UIImage(named: "empty_user")
        } else {
            cell.friend = friendsList[indexPath.row]
        }
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        
        if lastSelectedCellIndexPath != nil {
            var lastSelectedCell = collectionView.cellForItemAtIndexPath(lastSelectedCellIndexPath) as FriendCollectionViewCell
            lastSelectedCell.cellSelectOverlayView.hidden = true
        }
        
        var thisCell = collectionView.cellForItemAtIndexPath(indexPath) as FriendCollectionViewCell
        
        thisCell.cellSelectOverlayView.hidden = false
        UIView.animateWithDuration(0.7, animations: { () -> Void in
            thisCell.cellSelectOverlayView.alpha = 0
        }) { (finished) -> Void in
            //thisCell.cellSelectOverlayView.hidden = true
            thisCell.cellSelectOverlayView.alpha = 0.7
            
            self.delegate?.newOpponentSubmitted(self.friendsList[indexPath.row])
        }
        
        lastSelectedCellIndexPath = indexPath
    }

    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var mElementSize = CGSizeMake(view.frame.width/3, view.frame.width/3)
        
        return mElementSize
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
