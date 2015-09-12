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
import Parse
import ParseUI

enum LoginSource: String {
    case Facebook = "Facebook"
}

class Authentication {
    let realm = Realm()
    //let memoryRealm = Realm(configuration: Realm.Configuration(inMemoryIdentifier: "memoryRealm"))
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let loginVC = "LoginVC"
    
    var isUserInfoPopulated: Bool = false {
        didSet {
            if isUserInfoPopulated {
                self.registerForAPNS(UIApplication.sharedApplication())
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        println(getLoginSource())
        if getLoginSource() != "" {
            return true
        } else {
            return false
        }
    }
    
    func getLoginSource() -> String {
        if let user = realm.objects(Users).first {
            return user.userAuthSource
        } else {
            return ""
        }

    }
    
    func logout() {
        PFUser.logOut()
        var currentUser = PFUser.currentUser()
        goToLoginVC(true)
    }
    
    func getUserDetails() -> (name: String, email: String) {
    
        if let user = PFUser.currentUser() {
            user.fetchFromLocalDatastoreInBackground()
            if let name = user.valueForKey("name") as? String {
                if let email = user.email {
                    return (name,email)
                } else {
                    return (name,"")
                }
            } else {
                return ("","")
            }
            
        } else {
            return ("","")
        }
        
    }
    
    func goToLoginVC (shouldAnimate: Bool) {
        let logInController = LoginVC()
        logInController.fields = (
            PFLogInFields.UsernameAndPassword
            | PFLogInFields.LogInButton
            //| PFLogInFields.SignUpButton
            | PFLogInFields.Facebook
            //| PFLogInFields.Twitter
            | PFLogInFields.PasswordForgotten)
        self.appDel.window?.rootViewController!.presentViewController(logInController, animated: shouldAnimate, completion: nil)
    }
    
    func goToInitialVC () {
        self.appDel.window?.rootViewController = self.mainStoryboard.instantiateInitialViewController() as? UIViewController
    }
    
    func setDeviceToken(token: String) {
        if let user = realm.objects(Users).first {
            realm.write {
                user.userAPNSToken = token
                //self.realm.add(user)
            }
        }
    }
    
    func registerForAPNS(application: UIApplication) {
        application.registerForRemoteNotifications()
    }
    
    func requestUserNotificationPermission(application: UIApplication) {
        var settings = UIUserNotificationSettings(forTypes: .Badge | .Alert | .Sound, categories: nil)
        application.registerUserNotificationSettings(settings)
    }
    
    func isFirstTimeUser(email: String) -> Bool {
        var emailCount = realm.objects(Users).filter("userEmail = '\(email)'").count

        if emailCount > 0 { // user exists
            return false
        } else {
            let userObject = Users()
            userObject.userEmail = email
            userObject.userRegisteredDateTime = NSDate().formattedDateTimeToString("yyyy-MM-dd'T'HH:mm:ssz")
            realm.write {self.realm.add(userObject)}
            return true
        }
    }
}

class ServerAuth: Authentication {
    let baseURL = "http://52.25.48.116:9000/api/"
    var isRegisteredOnServer: (status: Bool,email: String?) = (false, nil) {
        didSet {
            if let email = isRegisteredOnServer.email {
                if let user = self.realm.objects(Users).filter("userFBEmail = '\(email)'").first {
                    if isRegisteredOnServer.status {
                        putServerUserInfo("users/update", object: user.toDictionary() as! [String : AnyObject])
                    } else {
                        postServerUserInfo("users/create", object: user.toDictionary() as! [String : AnyObject])
                    }
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
    
    func setServerUserInfo(email: String) {
        if let user = self.realm.objects(Users).filter("userEmail = '\(email)'").first {
            self.isRegisteredOnServer(user.userEmail)
        }
    }
    
    func isRegisteredOnServer(userEmail: String) {
        
        Alamofire.request(.GET, "http://52.25.48.116:9000/api/users/\(userEmail)").responseJSON { _, _, data, error in
            if let anError = error {
                println("error calling GET on /posts/1")
                println(error)
            } else if let data: AnyObject = data {
                let user = JSON(data)
                if let responseEmail = user["userEmail"].string {
                    if responseEmail == userEmail {
                        self.isRegisteredOnServer = (true, responseEmail)
                    } else {
                        println("Non-matching response")
                    }
                } else {
                    self.isRegisteredOnServer = (false,nil)
            }

        }
    }
    }
}

    // MARK: - Facebook Login Methods

class FacebookAuth: Authentication {

    var fbAccessTokenAvailable: (tokenAvailable: Bool, tokenString: String) {
        if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
            return (true, fbAccessToken.tokenString)
        } else {
            return (false, "")
        }
    }
    
    func loginToFacebook () {
        let fbReadPermissions = ["public_profile", "email", "user_friends"]
        
        FBSDKLoginManager().logInWithReadPermissions(fbReadPermissions, handler: { (result, error) -> Void in
            if let fbError = error {
                //handle error
            } else if (result.isCancelled) {
                self.goToLoginVC(false)
            } else {
                if result.grantedPermissions.contains("email") {
                    self.goToInitialVC()
                }
            }
        })
    }
    
    func setFBUserInfo() {
        //println("Setting FB user info")
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture"]).startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if let fbError = error {
                //handle error
                println(fbError)
            } else {
                let fbRequestResults = result as! NSDictionary
                var user = PFUser.currentUser()
                
                user?.setObject(fbRequestResults["email"]!, forKey: "email")
                user?.setObject(fbRequestResults["email"]!, forKey: "username")
                user?.setObject(fbRequestResults["first_name"]!, forKey: "firstName")
                user?.setObject(fbRequestResults["last_name"]!, forKey: "lastName")
                user?.setObject(fbRequestResults["name"]!, forKey: "name")
                //user?.setObject(fbRequestResults["picture"]!, forKey: "picURL")
                
                user?.pinInBackground()
                user!.saveEventually()
                

            }
        })
    }

}
