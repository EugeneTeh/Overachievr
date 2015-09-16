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
    
    var objects: [AnyObject] = []
    var assigneeList: [(groupName: String, description: String, assignees: NSArray)] = [] {
        didSet {
            shouldUpdateFromServer = true
            if assigneeList.count == 0 {
                shouldShowFillerPanel = true
            } else {
                shouldShowFillerPanel = false
            }
            refreshView()
        }
    }
    var fillerPanel: UIView? = nil
    var shouldUpdateFromServer: Bool = true
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
        
        // clear title of back bar button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getAssigneesFromLocalDatastore()
        if shouldUpdateFromServer {
            refreshLocalDataStoreFromServer()
        }
        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (self.refreshControl!.refreshing) {
                self.refreshControl!.endRefreshing()
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.tableView.reloadData()
        })
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
            let group = assigneeList[self.tableView.indexPathForSelectedRow()!.row] as (groupName: String, description: String, assignees: NSArray)
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
        
        if assigneeList.count > 0 {
            cell.textLabel?.text = assigneeList[indexPath.row].groupName
            cell.detailTextLabel?.text = assigneeList[indexPath.row].description
        }
        
        return cell
    }
    
    func getAssigneesFromLocalDatastore() {
        println("Getting assignees from local datastore")
        let parseHelper = ParseHelper()
        parseHelper.getUserRelatedTasksQuery().fromLocalDatastore().findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                var list: [(groupName: String, description: String, assignees: NSArray)] = []
                // get unique assignees to group them
                if let objects = objects {
                    self.objects = objects
                    if objects.count == 0 {
                        self.assigneeList = []
                    } else {
                        for object in objects {
                            if let assignees = object.valueForKey("taskAssignedTo") as? NSArray {
                                var groupName: String = ""
                                var description: String = ""
                                for assignee in assignees {
                                    groupName += assignee.valueForKey("name") as! String + " "
                                    description += assignee.valueForKey("email") as! String + " "
                                }
                                list += [(groupName: groupName, description: description, assignees: assignees)]
                            }
                        }
                        list = parseHelper.removeDuplicateAssignees(list)
                        self.assigneeList = list
                    }
                }
            } else {
                println(error)
            }
        }
    }
    
    func refreshLocalDataStoreFromServer() {
        println("Refreshing local datastore from server")   
        let parseHelper = ParseHelper()
        parseHelper.getUserRelatedTasksQuery().findObjectsInBackgroundWithBlock {
            (parseObjects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                println("Found \(parseObjects!.count) parseObjects from server")
                // unpin all existing objects
                
                    PFObject.unpinAllInBackground(self.objects, block: { (succeeded: Bool, error: NSError?) -> Void in
                        if error == nil {
                            // Pin all new objects
                            PFObject.pinAllInBackground(parseObjects, block: { (succeeded: Bool, error: NSError?) -> Void in
                                if error == nil {
                                    // Once we've updated the local datastore, update the view with local datastore
                                    self.shouldUpdateFromServer = false
                                    self.getAssigneesFromLocalDatastore()
                                    
                                    // Refresh Push channel subscriptions
                                    var channels: [String] = []
                                    if let parseObjects = parseObjects {
                                        for parseObject in parseObjects {
                                            if let taskID = parseObject.valueForKey("taskID") as? String {
                                                channels.append(taskID)
                                            }
                                        }
                                    }
                                    parseHelper.subscribeToPushChannels(channels)
                                } else {
                                    println("Failed to pin objects")
                                }
                            })
                        } else {
                            println("Couldn't get objects")
                        }
                    })
            }
        }
    }

}
