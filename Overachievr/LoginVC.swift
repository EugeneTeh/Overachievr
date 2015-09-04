//
//  LoginVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/7/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
//import FBSDKCoreKit
//import FBSDKLoginKit
import Parse
import ParseUI

class LoginVC: PFLogInViewController, PFLogInViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.logInView?.backgroundColor = UIColor(patternImage: UIImage(named: "LogoBackground.pdf")!)
        self.logInView?.logo = UIImageView(image: UIImage(named: "LogoMedal.pdf"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.logInView?.logo?.frame = CGRectMake(0,self.logInView!.facebookButton!.center.y - 500, 120, 190)
        self.logInView?.logo?.center.x = self.view.center.x
        
        //self.logInView?.usernameField?.frame = CGRectMake(0, self.logInView!.facebookButton!.center.y - 280, self.logInView!.facebookButton!.frame.width, 50)
        //self.logInView?.usernameField?.center.x = self.view.center.x
    }
    
    
    // MARK: - Parse Login
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        var alert = UIAlertController()
        
        if !username.isEmpty {
            return true
        } else if !password.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}