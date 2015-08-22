//
//  AppDelegate.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/3/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Fabric
import Crashlytics



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics()])
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
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
        
        //println(Realm.defaultPath)
        FBSDKAppEvents.activateApp()
        
        
        // Check if user is logged in
        
        let fbAuthCheck = FacebookAuth()
        
        if fbAuthCheck.fbAccessTokenAvailable {
            println("token exists")
            if fbAuthCheck.fbEmail != "" {
                AddressBook().getAddressBookNames()
                fbAuthCheck.setFBUserInfo()
            }
            fbAuthCheck.goToIntialVC()
        } else {
            fbAuthCheck.goToLoginVC()
        }
        
    }


    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        // self.saveContext()
    }

// MARK: - Push Notifications
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if let activity = userInfo["activity"] as? String {
            if activity == "New" {
                if let taskID = userInfo["taskID"] as? String {
                    TaskHelper().getAssignedTask(taskID)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadTasksMainVC", object: nil)
                    completionHandler (UIBackgroundFetchResult.NewData)
                    
                }
            }
        }
        
        
    }

    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Authentication().setDeviceToken(deviceToken.description)
        ServerAuth().setServerUserInfo()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println(error.localizedDescription)
    }
    
}

