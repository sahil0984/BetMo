//
//  LaunchViewController.swift
//  BetMo
//
//  Created by Sahil Amoli on 10/29/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet weak var betmoLogo: UIImageView!
    @IBOutlet weak var punchImage: UIImageView!
    @IBOutlet weak var boomImage: UIImageView!

    var center: CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        punchImage.hidden = true
        betmoLogo.alpha = 0
        boomImage.alpha = 0
    }

    override func viewDidAppear(animated: Bool) {
        center = punchImage.frame.origin
        punchImage.frame.origin = CGPoint(x: 0, y: self.view.frame.height - punchImage.frame.height)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.punchImage.hidden = false
        }) { (Bool) -> Void in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.punchImage.frame.origin = self.center
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.boomImage.alpha = 1
                }, completion: { (Bool) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.betmoLogo.alpha = 1
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(2, animations: { () -> Void in
                            //nothing
                        }, completion: { (Bool) -> Void in
                            var storyboard = UIStoryboard(name: "Main", bundle: nil)
                            var vc: UIViewController!
                            if PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
                                vc = storyboard.instantiateViewControllerWithIdentifier("HomeViewController") as! UIViewController
                            } else {
                                vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! UIViewController
                            }
                            self.showViewController(vc, sender: self)
                        })
                    })
                })
            })
        }
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
