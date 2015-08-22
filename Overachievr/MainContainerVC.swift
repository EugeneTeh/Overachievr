//
//  MainContainerVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/21/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

class MainContainerVC: UIViewController {
    
    let mainContainerLeftPanelOffset: CGFloat = 120
    let panelTableViewTopInset: CGFloat = 68.0
    var keyboardFrame: CGRect = CGRectZero
    
    // Panel elements
    let leftMenuPanelCV: UIView = UIView()
    var leftMenuPanelTVC: LeftMenuPanelTVC?
    let createTaskPanelCV: UIView = UIView()
    var createTaskTextField: UITextField?
    
    // Panel toggle
    var leftMenuPanelExpanded: Bool = false
    var createTaskPanelExpanded: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftMenuPanelGestureRecognizers()
        addCreateTaskPanelGestureRecognizers()
        registerForKeyboardNotifications()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func leftMenuPanelTapped(sender: AnyObject) {
        toggleLeftMenuPanel(!leftMenuPanelExpanded)

    }
    
    @IBAction func createTaskButtonTapped(sender: AnyObject) {
        toggleCreateTaskPanel(!createTaskPanelExpanded)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}

