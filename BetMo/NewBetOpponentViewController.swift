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
    
    var allFriendsList: [User] = []
    var friendsList: [User] = []
    
    var openBetFriend = User()
    
    var lastSelectedCellIndexPath: NSIndexPath!
    
    var isFriendListLoaded = false
    var preLoadFriends: Bool = false {
        didSet {
            BetMoClient.sharedInstance.getAllBetMoFriends({(betMoFriendsList, error) -> () in
                if error == nil {
                    self.allFriendsList = betMoFriendsList!
                    //self.updateFriendsList()
                    println("Friends list preloaded")
                    self.isFriendListLoaded = true
                } else {
                    println(error)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        friendListCollectionView.dataSource = self
        friendListCollectionView.delegate = self
        friendListCollectionView.backgroundColor = UIColor.whiteColor()
        
        friendSearchBar.barTintColor = UIColor.whiteColor()
        friendSearchBar.delegate = self
        
        openBetFriend.setFirstName("Open Bet")
        openBetFriend.setLastName("")
        
        
        if isFriendListLoaded {
            updateFriendsList()
        } else {
            BetMoClient.sharedInstance.getAllBetMoFriends({(friendsList, error) -> () in
                if error == nil {
                    self.allFriendsList = friendsList!
                    self.updateFriendsList()
                    println("Friends list preloaded")
                    self.isFriendListLoaded = true
                } else {
                    println(error)
                }
            })
        }
        
    }
    
    func updateFriendsList() {
        var searchString = friendSearchBar.text.lowercaseString
        
        if searchString == "" {
            self.friendsList = allFriendsList
        } else {
            self.friendsList = []
            //regex searchString with seachName column of allFriendsList
            for friend in allFriendsList {
                var searchName = friend.getSearchName()
                if let match = searchName!.rangeOfString(searchString, options: .RegularExpressionSearch) {
                    self.friendsList.append(friend)
                }
            }
        }
        self.friendsList.insert(self.openBetFriend, atIndex: 0)
        self.friendListCollectionView.reloadData()
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //println("Edit changed")
        updateFriendsList()
    }
    
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendsList.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //var cell = collectionView.dequeueReusableCellWithIdentifier("FriendCell") as FriendTableViewCell
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCollectionViewCell
        
        if indexPath.row == 0 {
            cell.cellSelectOverlayView.hidden = true
            cell.friendNameLabel.text = "Open Bet"
            cell.friendImageView.image = UIImage(named: "empty_user")
        } else {
            cell.friend = friendsList[indexPath.row]
        }
        
        cell.friendNameLabel.font = UIFont(name: "OpenSans-Semibold", size: 13)

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        
        if lastSelectedCellIndexPath != nil {
            var lastSelectedCell = collectionView.cellForItemAtIndexPath(lastSelectedCellIndexPath) as! FriendCollectionViewCell
            lastSelectedCell.cellSelectOverlayView.hidden = true
        }
        
        var thisCell = collectionView.cellForItemAtIndexPath(indexPath) as! FriendCollectionViewCell
        
        thisCell.cellSelectOverlayView.hidden = false
        UIView.animateWithDuration(0.7, animations: { () -> Void in
            thisCell.cellSelectOverlayView.alpha = 0
        }) { (finished) -> Void in
            thisCell.cellSelectOverlayView.alpha = 0.6
            
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
