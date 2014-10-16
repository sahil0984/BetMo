//
//  AppDelegate.swift
//  BetMo
//
//  Created by Sahil Arora on 10/8/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)

    var parseAppId = "HLJvIWanJTZ4VmdUarEbbUPxpR9eYsaUNFiyodKe"
    var parseClientKey = "4umyNwPmXgax1yNsvEWizzsaOt7C5ryuHvIzI4Zu"


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        //Initialize Parse and Facebook
        Parse.setApplicationId(parseAppId, clientKey: parseClientKey)
        PFFacebookUtils.initializeFacebook()
        
        //Parse Analytics to track app usage
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        
        //Register for Push Notifications for both pre and post iOS 8
        if application.respondsToSelector(Selector("registerUserNotificationSettings:")) {
            // Register for Push Notitications, if running iOS 8
            var userNotficationTypes = (UIUserNotificationType.Alert |
                                        UIUserNotificationType.Badge |
                                        UIUserNotificationType.Sound)
            var settings = UIUserNotificationSettings(forTypes: userNotficationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Register for Push Notifications before iOS 8
            var userNotficationTypes = (UIRemoteNotificationType.Alert |
                                        UIRemoteNotificationType.Badge |
                                        UIRemoteNotificationType.Sound)
            application.registerForRemoteNotificationTypes( userNotficationTypes )
        }
        
        
        //Add a notification center to monitor logout action
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout", name: "userDidLogoutNotification", object: nil)

        //If user is cached and linked to Facebook
        if PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
            var vc = storyboard.instantiateViewControllerWithIdentifier("HomeNavigationViewController") as UIViewController
            window?.rootViewController = vc
        }
        
        return true
    }

    func userDidLogout() {
        //Clear session tokens
        PFFacebookUtils.session().closeAndClearTokenInformation()
        
        //Is this needed??
        PFUser.logOut()

        //Go to initial login view controller
        var vc = storyboard.instantiateInitialViewController() as UIViewController
        window?.rootViewController = vc
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        // Store the deviceToken in the current installation and save it to Parse.
        //var currentInstallation = PFInstallation()
        var currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        println("\(deviceToken)")
        currentInstallation.saveInBackgroundWithBlock { (isSaved, error: NSError!) -> Void in
            if isSaved {
                println("\(error)")
                
            } else {
                println("\(error)")
            }
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: NSDictionary) {
        
        PFPush.handlePush(userInfo)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        //Close the Facebook session
        PFFacebookUtils.session().close()
    }

    //openURL call for Facebook
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String,
        annotation: AnyObject?) -> Bool {
            return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication,
                withSession:PFFacebookUtils.session())
    }

}

