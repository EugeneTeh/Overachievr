//
//  TaskGroupsTVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/26/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import RealmSwift


protocol TaskGroupsDelegate {
    func didSelectGroupAtIndexPath(groupID: String)
}

class TaskGroupsTVC: UITableViewController {
    
    var uniqueAssignees = Set(Realm().objects(TaskAssignee).valueForKey("assigneeEmail") as! [String])
    var assigneeList = []
    let realm = Realm()
    var delegate: TaskGroupsDelegate?
    var fillerPanel: UIView? = nil
    
    var showFillerPanel: Bool = false {
        didSet {
            if fillerPanel == nil {
                toggleFillerPanel(showFillerPanel)
            } else {
                if showFillerPanel == false {
                    toggleFillerPanel(showFillerPanel)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(Realm.defaultPath)
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: Selector("refreshView"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        uniqueAssignees = Set(Realm().objects(TaskAssignee).valueForKey("assigneeEmail") as! [String])

        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        if uniqueAssignees.count == 0 {
            showFillerPanel = true
        } else {
            showFillerPanel = false
        }
        refreshView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshView() {
        println("View refreshed")
        dispatch_async(dispatch_get_main_queue()) {
            
            if (self.refreshControl!.refreshing) {
                self.refreshControl!.endRefreshing()
            }
            
            self.tableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func toggleFillerPanel(shouldShow: Bool) {
        if shouldShow {
            setupFillerPanel()
        } else {
            //fillerPanel!.subviews.map({ $0.removeFromSuperview() })
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
        createTaskButton.center = self.view.center
        createTaskButton.addTarget(self, action: "createTaskButtonTapped:", forControlEvents: .TouchUpInside)
        
        
        let letsGetStartedLabel = UILabel()
        letsGetStartedLabel.frame = CGRect(x: 0, y: 0, width: 260, height: 260)
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
    
    @IBAction func addGroupBarButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("createTaskSegue", sender: nil)
    }
    
    @IBAction func unwindToTaskGroups(segue:UIStoryboardSegue) {

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
        
        return uniqueAssignees.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskGroupsCell", forIndexPath: indexPath) as! UITableViewCell
        
        assigneeList = Array(uniqueAssignees)
        let groups = Realm().objects(TaskAssignee).filter("assigneeEmail = '\(assigneeList[indexPath.row])'")

        // Configure the cell...
        cell.textLabel!.text = groups[0].assigneeName
        cell.detailTextLabel!.text = groups[0].assigneeEmail

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)

        performSegueWithIdentifier("selectedTaskGroupSegue", sender: nil)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectedTaskGroupSegue" {
            let group = assigneeList[self.tableView.indexPathForSelectedRow()!.row] as! String
            let destinationVC = segue.destinationViewController as! CollaboratorTVC

            destinationVC.didSelectGroup(group)
        }

    }


}

