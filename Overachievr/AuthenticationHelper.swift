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
import RealmSwift
import Alamofire
import SwiftyJSON

enum LoginSource: String {
    case Facebook = "Facebook"
}

class Authentication {
    let realm = Realm()
    let userObject = Users()
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let loginVC = "LoginVC"

    
    func getLoginSource () -> String {
        if let user = realm.objects(Users).first {
            return user.userAuthSource
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
        if let user = realm.objects(Users).first {
            realm.write {
                user.userAPNSToken = token
                self.realm.add(user)
            }
        }
    }
    
    func registerForAPNS(application: UIApplication) {
        var settings = UIUserNotificationSettings(forTypes: .Badge | .Alert | .Sound, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func isFirstTimeUser(email: String) -> Bool {
        if self.realm.objects(Users).filter("userPrimaryEmail = '\(email)'").count > 0 {
            return false
        } else {            
            self.userObject.userPrimaryEmail = email
            self.userObject.userIsRegistered = true
            self.userObject.userRegisteredDateTime = NSDate().formattedDateTimeToString("yyyy-MM-dd'T'HH:mm:ssz")
            realm.write {self.realm.add(self.userObject)}
            return true
        }
    }
}

class ServerAuth: Authentication {
    let baseURL = "http://52.25.48.116:9000/api/"
    var isRegisteredOnServer: Bool = false {
        didSet {
            if let user = self.realm.objects(Users).first {
                if isRegisteredOnServer {
                    putServerUserInfo("users/update", object: user.toDictionary() as! [String : AnyObject])
                } else {
                    postServerUserInfo("users/create", object: user.toDictionary() as! [String : AnyObject])
                }
            }
        }
    }
    
    
    
    func postServerUserInfo(path: String, object: [String: AnyObject]) {
        Alamofire.request(Alamofire.Method.POST, "\(self.baseURL)\(path)", parameters: object, encoding: Alamofire.ParameterEncoding.JSON)
    }
    
    func putServerUserInfo(path: String, object: [String: AnyObject]) {
        Alamofire.request(Alamofire.Method.PUT, "\(self.baseURL)\(path)", parameters: object, encoding: Alamofire.ParameterEncoding.JSON)
    }
    
    func setServerUserInfo() {
        if let user = self.realm.objects(Users).first {
            self.isRegisteredOnServer(user.userPrimaryEmail)
        }
    }
    
    func isRegisteredOnServer(userEmail: String) {
        
        Alamofire.request(.GET, "http://52.25.48.116:9000/api/users/\(userEmail)").responseJSON { _, _, data, error in
            if let anError = error {
                println("error calling GET on /posts/1")
                println(error)
            } else if let data: AnyObject = data {
                let user = JSON(data)
                if let responseEmail = user["userPrimaryEmail"].string {
                    if responseEmail == userEmail {
                        self.isRegisteredOnServer = true
                    } else {
                        println("Non-matching response")
                    }
                } else {
                    self.isRegisteredOnServer = false
            }

        }
    }
    }
}

    // MARK: - Facebook Login Methods

class FacebookAuth: Authentication {
    let fbReadPermissions = ["public_profile", "email", "user_friends"]
    var isUserInfoPopulated: Bool = false {
        didSet {
            if isUserInfoPopulated {
                self.registerForAPNS(UIApplication.sharedApplication())
            }
        }
    }
    var fbName: String {
        if let user = self.realm.objects(Users).first {
            return user.userFBName
        } else {
            return ""
        }
    }
    var fbEmail: String {
        if let user = self.realm.objects(Users).first {
            return user.userFBEmail
        } else {
            return ""
        }
    }

    var fbAccessTokenAvailable: Bool {
        if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
            return true
        } else {
            return false
        }
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
    
    func setFBUserInfo() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture"]).startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if let fbError = error {
                //handle error
                println(fbError)
            } else {
                let fbRequestResults = result as! NSDictionary
                
                // ensure user exists in DB
                if let userEmail = fbRequestResults.valueForKey("email") as? String {
                    self.isFirstTimeUser(userEmail)
                }
                
                // update user record
                
                self.realm.write {
                    self.userObject.userAuthSource = LoginSource.Facebook.rawValue
                    for (key, value) in fbRequestResults {
                        if key as! String == "id" {
                            self.userObject.userFBID = value as! String
                        } else if key as! String == "name" {
                            self.userObject.userFBName = value as! String
                        } else if key as! String == "first_name" {
                            self.userObject.userFBFirstName = value as! String
                        } else if key as! String == "last_name" {
                            self.userObject.userFBLastName = value as! String
                        } else if key as! String == "email" {
                            self.userObject.userFBEmail = value as! String
                        } else if key as! String == "picture" {
                            println(key)                        }
                    }
                }
                self.isUserInfoPopulated = true
            }
        })
    }

}
