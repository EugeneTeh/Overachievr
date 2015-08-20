//
//  LoginVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/7/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginVC: UIViewController {
    
    let fbAuthCheck = FacebookAuth()

    @IBOutlet weak var fbLoginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        //Wait for Facebook Token change
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTokenUpdated:", name:FBSDKAccessTokenDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func fbButtonPressed (sender: AnyObject) {
        fbAuthCheck.loginToFacebook()
        
    }
    
    func onTokenUpdated(notification: NSNotification) {
        if fbAuthCheck.fbAccessTokenAvailable {
            fbAuthCheck.setFBUserInfo()
        }
    }

}