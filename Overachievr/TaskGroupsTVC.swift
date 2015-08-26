//
//  TaskGroupsTVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/26/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import RealmSwift
import FBSDKCoreKit

class TaskGroupsTVC: UITableViewController {
    
    let taskAssignees = Realm().objects(TaskAssignee)
    let realm = Realm()
    
    var fillerPanelShouldShow: Bool = false {
        didSet {
            toggleFillerPanel(fillerPanelShouldShow)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(Realm.defaultPath)
        
        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: Selector("refreshView"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        
        if taskAssignees.count == 0 {
            fillerPanelShouldShow = true
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
            shouldShow
        } else {
            self.view.subviews.map({ $0.removeFromSuperview() })
        }
    }
    
    func setupFillerPanel() {
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
        
        
        self.view.addSubview(createTaskButton)
        self.view.addSubview(letsGetStartedLabel)
    }
    
    func createTaskButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("createTaskSegue", sender: nil)
    }
    
    @IBAction func addGroupBarButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("createTaskSegue", sender: nil)
    }
    
    @IBAction func unwindToTaskGroups(segue:UIStoryboardSegue) {
        self.refreshView()
        
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
        
        return taskAssignees.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskGroupsCell", forIndexPath: indexPath) as! UITableViewCell
        let taskAssignee = taskAssignees[indexPath.row]
        
        // Configure the cell...
        cell.textLabel!.text = taskAssignee.assigneeName
        cell.detailTextLabel!.text = taskAssignee.assigneeEmail

        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
