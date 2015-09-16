//
//  SettingsTabTVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/21/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

class SettingsTabTVC: UITableViewController {
    
    let mainContainerLeftPanelOffset: CGFloat = 120
    let panelTableViewTopInset: CGFloat = 68.0
    let leftMenuPanelCV: UIView = UIView()
    
    var menuItems: Array<String> = ["Logout"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Not working yet
    @IBAction func handleLeftEdgePan(gesture: UIScreenEdgePanGestureRecognizer) {
        print("Left edge touched")
        let translation: CGPoint = gesture.translationInView(self.view)
        let width: CGFloat = CGRectGetWidth(self.view.frame) - self.mainContainerLeftPanelOffset
//        let percentage = max(gesture.translationInView(self.view).x, 0) / width
        
            switch gesture.state {
            case UIGestureRecognizerState.Began:
                print("Begin pan")
                
            case UIGestureRecognizerState.Changed:
                print("Update frame")
                
                leftMenuPanelCV.frame = CGRectMake(translation.x/3, 0, width, self.view.frame.height)
            default:
                print("Pan end")
                
            }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return menuItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("SettingsCell")
        
        cell?.textLabel?.text = menuItems[indexPath.row]
        

        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            Authentication().logout()
        }
    }


}
