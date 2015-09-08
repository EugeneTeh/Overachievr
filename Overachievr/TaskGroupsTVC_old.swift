//
//  TaskGroupsTVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/26/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol TaskGroupsDelegate {
    func didSelectGroupAtIndexPath(groupID: String)
}

class TaskGroupsTVC_OLD: PFQueryTableViewController {
    
    //let userDetails = Authentication().getUserDetails()
    
    
    var delegate: TaskGroupsDelegate?
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
        
        
        //println(Realm.Configuration.defaultConfiguration.path)
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: Selector("refreshView"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshView()

        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

    }
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "Task"
        self.textKey = "taskCreatorName"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
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
            self.loadObjects()
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            println("View refreshed")
        }
    }
    
    override func objectsWillLoad() {
        self.baseQuery().fromLocalDatastore().findObjectsInBackgroundWithBlock {
            ( parseObjects: [AnyObject]?, error: NSError?) -> Void in
            if let error = error {
                //handle error
            } else {
                if let objects = parseObjects {
                    if objects.count == 0 {
                        self.shouldShowFillerPanel = true
                    } else {
                        self.shouldShowFillerPanel = false
                    }
                }
            }
        }
    }
    

    // MARK: - Table view controls
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let object = self.objectAtIndexPath(indexPath)
            
            object?.deleteEventually()
            object?.unpinInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if error == nil {
                    println("\(NSDate()) Object unpin status: \(success). No errors.")
                    self.refreshView()
                } else {
                    println("\(NSDate()) Unpin object error: \(error)")
                }
            }
        }
    }
    
    

    // MARK: - Table view data source
    
    override func queryForTable() -> PFQuery {
        return self.baseQuery().fromLocalDatastore()
    }
    
    func baseQuery() -> PFQuery {
        var query = PFQuery(className: "Task")
        let userDetails = Authentication().getUserDetails()
        query.whereKey("taskCreatorEmail", equalTo: userDetails.email)
        query.orderByAscending("updatedAt")
    
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("TaskGroupsCell") as! PFTableViewCell!
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TaskGroupsCell")
        }
        
        let assignees = object?["taskAssignedTo"] as! NSArray
        var names = ""
        var emails = ""

            for object in assignees {
                names += (object.valueForKey("name") as? String)! + " "
                emails += (object.valueForKey("email") as? String)! + " "
            }

        
        cell.textLabel?.text = names
        cell.detailTextLabel?.text = emails
        return cell
    }

    
    func refreshLocalDataStoreFromServer() {
        self.baseQuery().findObjectsInBackgroundWithBlock { ( parseObjects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                println("Found \(parseObjects!.count) parseObjects from server")
                // First, unpin all existing objects
                PFObject.unpinAllInBackground(self.objects, block: { (succeeded: Bool, error: NSError?) -> Void in
                    if error == nil {
                        // Pin all the new objects
                        PFObject.pinAllInBackground(parseObjects, block: { (succeeded: Bool, error: NSError?) -> Void in
                            if error == nil {
                                // Once we've updated the local datastore, update the view with local datastore
                                //self.shouldUpdateFromServer = false
                                self.loadObjects()
                            } else {
                                println("Failed to pin objects")
                            }
                        })
                    }
                })
            } else {
                println("Couldn't get objects")
            }
        }
    }
    


    /*
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)

        performSegueWithIdentifier("selectedTaskGroupSegue", sender: nil)
    }
*/


    // MARK: - Navigation
    
    @IBAction func addGroupBarButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("createTaskSegue", sender: nil)
    }
    
    @IBAction func unwindToTaskGroups(segue:UIStoryboardSegue) {
        
    }



    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectedTaskGroupSegue" {
            //let group = assigneeList[self.tableView.indexPathForSelectedRow()!.row] as! String
            let destinationVC = segue.destinationViewController as! CollaboratorTVC

            //destinationVC.didSelectGroup(group)
        }

    }
    
    
    
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

