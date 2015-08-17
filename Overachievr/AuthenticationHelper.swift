//
//  AuthenticationHelper.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/8/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

enum LoginSource: String {
    case Facebook = "Facebook"
}

class Authentication {
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let loginVC = "LoginVC"
    
    func getLoginSource () -> String {
        if let source = defaults.valueForKey("Overachievr_loggedInVia") as? String {
            return source
        } else {
            return ""
        }
    }
    
    func resetLogin () {
        if self.getLoginSource() == LoginSource.Facebook.rawValue {
            FBSDKAccessToken.setCurrentAccessToken(nil)
            FBSDKLoginManager().logOut()
        }
    }
    
    func goToLoginVC () {
        self.appDel.window?.rootViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier(self.loginVC) as? UIViewController
    }
    
    func goToIntialVC () {
        self.appDel.window?.rootViewController = self.mainStoryboard.instantiateInitialViewController() as? UIViewController
    }
    
    func setDeviceToken(token: String) {
        self.defaults.setObject(token, forKey: "Overachievr_APNToken")
    }
    
    func setServerUserInfo() {
        if self.getLoginSource() == LoginSource.Facebook.rawValue {
            for key in self.defaults.dictionaryRepresentation().keys {
                
                println(key)
            }
            let firstTimeUser = self.defaults.boolForKey("Overachievr_FirstLaunch")
            if firstTimeUser {
                self.defaults.setObject(true, forKey: "Overachievr_FirstLaunch")
            }
            
        }
    }
    
    func registerForAPNS(application: UIApplication) {
        var settings = UIUserNotificationSettings(forTypes: .Badge | .Alert | .Sound, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
}


    // MARK: - Facebook Login Methods

class FacebookAuth: Authentication {
    let fbReadPermissions = ["public_profile", "email", "user_friends"]

    var fbAccessTokenAvailable: Bool {
        if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
            return true
        } else {
            return false
        }
    }
    
    func checkForProfileChanges () {
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        NSNotificationCenter.defaultCenter().addObserver(FacebookAuth.self, selector: "getFBUserData", name:FBSDKProfileDidChangeNotification, object: nil)
        
        println("Notification Check Enabled")
    }
    
    func loginToFacebook () {
        FBSDKLoginManager().logInWithReadPermissions(self.fbReadPermissions, handler: { (result, error) -> Void in
            
            if let fbError = error {
                //handle error
            } else {
                if result.grantedPermissions.contains("email") {
                    AddressBook().getAddressBookNames()
                    self.goToIntialVC()
                    
                }
            }
        })
    }
    
    func setFBNSUserDefaults() {
        
        //sample parameter string: ["fields": "id, name, first_name, last_name, picture.type(large), email"]
        
        if self.fbAccessTokenAvailable {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                
                if let fbError = error {
                    //handle error
                } else {
                    let fbRequestResults = result as! NSDictionary
                    
                    self.defaults.setObject(LoginSource.Facebook.rawValue, forKey: "Overachievr_loggedInVia")
                    
                    for (key, value) in fbRequestResults {
                        let newKey = ("Overachievr_fb_\(key)")
                        self.defaults.setObject(value, forKey: newKey)
                        
                        self.defaults.synchronize()
                    }
                    

                }
            })
        }
    }

    func getFBNSUserDefaults() -> (fbName: String, fbEmail: String) {
        if let fbName = defaults.valueForKey("Overachievr_fb_name") as? String,
            fbEmail = defaults.valueForKey("Overachievr_fb_email") as? String {
                return (fbName,fbEmail)
        } else {
            return ("","")
        }
    }

    
}
