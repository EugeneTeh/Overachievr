//
//  CollaboratorTVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/27/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class CollaboratorTVC: PFQueryTableViewController {
    
    var assignees: NSArray = []
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "Task"
        self.textKey = "taskDetails"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func refreshView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.loadObjects()
            self.tableView.reloadData()
            
            if (self.refreshControl!.refreshing) {
                self.refreshControl!.endRefreshing()
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            println("View refreshed")
        })
    }
    
    func didSelectGroup(groupDetails: (groupName: String, description: String, assignees: NSArray)) {
        self.assignees = groupDetails.assignees
        self.title = groupDetails.groupName
    }
    
    override func queryForTable() -> PFQuery {
        let parseHelper = ParseHelper()
        return parseHelper.getUserRelatedTasksWithSpecifiedAssigneeQuery(assignees).fromLocalDatastore()
    }
    
    // MARK: - Table view controls
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let object = self.objectAtIndexPath(indexPath)
            
            
            object?.unpinInBackground()
            removeObjectAtIndexPath(indexPath, animated: true)
            if let taskID = object?.valueForKey("taskID") as? String {
                ParseHelper().unsubscribeToPushChannel(taskID)
            } else {
                println("Did not unsubscribe to channel")
            }
            if let objects = self.objects {
                if objects.count == 0 {
                    performSegueWithIdentifier("returnToTaskGroupsSegue", sender: nil)
                }
            }
        }
    }

    // MARK: - Table view data source
    
    
    // MARK: -  Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToTaskGroupsSegue" {
            let destinationVC = segue.destinationViewController as! TaskGroupsTVC
            destinationVC.getAssigneesFromLocalDatastore()
        }
    }

}
