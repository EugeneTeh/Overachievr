//
//  FillerPanelExtension.swift
//  Overachievr
//
//  Created by Eugene Teh on 9/8/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//


import UIKit


extension TaskGroupsTVC {
    // MARK: - Filler Panel
    
    func toggleFillerPanel(shouldShow: Bool) {
        if shouldShow {
            setupFillerPanel()
        } else {
            if let fillerPanelExists = fillerPanel {
                fillerPanelExists.removeFromSuperview()
            }
            fillerPanel = nil
        }
    }
    
    func setupFillerPanel() {
        fillerPanel = UIView()
        fillerPanel?.frame = self.view.bounds
        
        let createTaskButton = UIButton()
        createTaskButton.setImage(UIImage(named: "button_CreateTask.pdf"), forState: .Normal)
        createTaskButton.frame = CGRect(x:0, y:0, width: 160, height: 40)
        createTaskButton.center.x = self.view.center.x
        createTaskButton.center.y = self.view.frame.height*0.6
        createTaskButton.addTarget(self, action: "createTaskButtonTapped:", forControlEvents: .TouchUpInside)
        
        
        let letsGetStartedLabel = UILabel()
        letsGetStartedLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.width*0.6,
            height: 260)
        letsGetStartedLabel.center.x = self.view.center.x
        letsGetStartedLabel.center.y = createTaskButton.center.y - 120
        letsGetStartedLabel.numberOfLines = 0
        letsGetStartedLabel.textAlignment = .Center
        letsGetStartedLabel.textColor = UIColor.lightGrayColor()
        letsGetStartedLabel.font = UIFont(name: "Avenir-Light", size: 18)
        letsGetStartedLabel.text = "You have no tasks out there right now. Tap the button below, or - SWIPE UP - to quickly create some!"
        
        
        fillerPanel!.addSubview(createTaskButton)
        fillerPanel!.addSubview(letsGetStartedLabel)
        self.view.addSubview(fillerPanel!)
    }
    
    func createTaskButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("createTaskSegue", sender: nil)
    }
}
