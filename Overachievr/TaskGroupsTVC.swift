//
//  TaskGroupsTVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 9/8/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import Parse



class TaskGroupsTVC: UITableViewController {
    
    var assigneeList: [(groupName: String, description: String, emails:[String])] = [] {
        didSet {
            if assigneeList.count == 0 {
                shouldShowFillerPanel = true
            } else {
                shouldShowFillerPanel = false
            }
        }
    }
    var fillerPanel: UIView? = nil
    var shouldShowFillerPanel: Bool = false {
        didSet {
            if fillerPanel == nil {
                toggleFillerPanel(shouldShowFillerPanel)
            } else {
                if shouldShowFillerPanel == false {
                    toggleFillerPanel(shouldShowFillerPanel)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: Selector("refreshView"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        getAssigneesFromLocalDatastore()
        
        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshView() {
        dispatch_async(dispatch_get_main_queue()) {
            
            if (self.refreshControl!.refreshing) {
                self.refreshControl!.endRefreshing()
            }
            //self.loadObjects()
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            println("View refreshed")
        }
    }
    
    // MARK: - Actions
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("selectedTaskGroupSegue", sender: nil)
    }
    
    @IBAction func addGroupBarButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("createTaskSegue", sender: nil)
    }
    
    @IBAction func unwindToTaskGroups(segue:UIStoryboardSegue) {
        
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectedTaskGroupSegue" {
            let group = assigneeList[self.tableView.indexPathForSelectedRow()!.row] as (groupName: String, description: String, emails: [String])
            let destinationVC = segue.destinationViewController as! CollaboratorTVC
            
            destinationVC.didSelectGroup(group)
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
        return assigneeList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskGroupsCell") as! UITableViewCell
        
        cell.textLabel?.text = assigneeList[indexPath.row].groupName
        cell.detailTextLabel?.text = assigneeList[indexPath.row].description
        
        return cell
    }
    
    func getAssigneesFromLocalDatastore() {
        getUserCreatedTasksQuery().fromLocalDatastore().findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        if let assignees = object.valueForKey("taskAssignedTo") as? NSArray {
                            var groupName: String = ""
                            var description: String = ""
                            var emails: [String] = []
                            for assignee in assignees {
                                groupName += assignee.valueForKey("name") as! String + " "
                                description += assignee.valueForKey("email") as! String + " "
                                emails += [assignee.valueForKey("email") as! String]
                            }
                            self.assigneeList += [(groupName: groupName, description: description, emails: emails)]
                        }
                    }
                }
                self.assigneeList = self.removeDuplicateAssignees(self.assigneeList)
                self.refreshView()
            } else {
                println(error)
            }
        }
    }

    func getUserCreatedTasksQuery() -> PFQuery {
        var query = PFQuery(className: "Task")
        let userDetails = Authentication().getUserDetails()
        query.whereKey("taskCreatorEmail", equalTo: userDetails.email)
        query.orderByAscending("updatedAt")
        
        return query
    }
    
    func removeDuplicateAssignees(array: [(groupName: String, description: String, emails: [String])]) -> [(groupName: String, description: String, emails: [String])] {
        var encountered = Set<String>()
        var result: [(groupName: String, description: String, emails: [String])] = []
        for value in array {
            if !encountered.contains(value.description) {
                // Add value to the set.
                encountered.insert(value.description)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }

}
