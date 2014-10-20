//
//  BetMoGetImage.swift
//  BetMo
//
//  Created by Sahil Arora on 10/18/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import Foundation

class BetMoGetImage {
    
    var imageCache = NSMutableDictionary()
    var ciContenxt = CIContext(options:nil)
    
    class var sharedInstance: BetMoGetImage {
        struct Static {
            static let instance = BetMoGetImage()
        }
        return Static.instance
    }
    
    
    func getUserImage(url: String?, completion: (userImage: UIImage?, error: NSError?) -> ()) {
        // Check our image cache for the existing key. This is just a dictionary of UIImages
        var userImage: UIImage? = self.imageCache.valueForKey(url!) as? UIImage
        
        if userImage == nil {
            // Make a network call to get user image
            var urlRequest = NSURLRequest(URL: NSURL(string: url!))
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
                if connectionError == nil && data != nil {
                    let image = UIImage(data: data!)
                    self.imageCache.setValue(image, forKey: url!)
                    completion(userImage: image, error:nil)
                } else {
                    completion(userImage: nil, error: connectionError)
                }
            }
            
        } else {
            completion(userImage: userImage, error:nil)
        }
    }
    
    func getUserBannerImage(url: String?, completion: (userBannerImage: UIImage?, error: NSError?) -> ()) {
        // Check our image cache for the existing key. This is just a dictionary of UIImages
        var userBannerImage: UIImage? = self.imageCache.valueForKey(url!) as? UIImage
        
        if userBannerImage == nil {
            // Make a network call to get user banner json response
            var urlRequest = NSURLRequest(URL: NSURL(string: url!))
            
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
                if connectionError == nil && data != nil {
                    var object = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as NSDictionary
                    
                    var coverObject =
                    object["cover"] as NSDictionary
                    var bannerRealUrl = coverObject["source"] as NSString
                    
                    var urlRequest = NSURLRequest(URL: NSURL(string: bannerRealUrl))
                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, connectionError: NSError?) -> Void in
                        if connectionError == nil && data != nil {
                            let image = UIImage(data: data!)
                            self.imageCache.setValue(image, forKey: url!)
                            completion(userBannerImage: image, error:nil)
                        } else {
                            completion(userBannerImage: nil, error: connectionError)
                        }
                    }
                    
                } else {
                    completion(userBannerImage: nil, error: connectionError)
                }
            }
            
        } else {
            completion(userBannerImage: userBannerImage, error:nil)
        }
    }
    
    func getSharedCIContext() -> CIContext {
        return self.ciContenxt
    }
}