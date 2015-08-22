//
//  LeftMenuPanelTVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/21/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

protocol LeftMenuPanelDelegate {
    func leftMenuPanelDidSelectRow(indexPath: NSIndexPath)
}

class LeftMenuPanelTVC: UITableViewController {
    
    var delegate: LeftMenuPanelDelegate?
    var menuItems: Array<String> = ["Logout"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("LeftMenuItemCell") as? UITableViewCell

        // Configure the cell...
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "LeftMenuItemCell")
            
            cell!.backgroundColor = UIColor.darkGrayColor()
            cell!.textLabel!.textColor = UIColor.lightTextColor()
            
            let selectedView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.width, height: cell!.frame.height))
            selectedView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
            
            cell!.selectedBackgroundView = selectedView
        }
        
        cell?.textLabel?.text = menuItems[indexPath.row]
        

        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.leftMenuPanelDidSelectRow(indexPath)
    }


}
