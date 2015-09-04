//
//  TasksMainVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/3/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import RealmSwift
import FBSDKCoreKit
import Crashlytics

class TasksMainVC: UITableViewController, UITableViewDelegate {
    
    let taskList = Realm().objects(Tasks).sorted("taskCreatedDateTime", ascending: false)
    let realm = Realm()
    var tempCounter = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshView", name: "reloadTasksMainVC", object: nil)
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: Selector("refreshView"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl!)
        
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let app = UIApplication.sharedApplication()
        app.applicationIconBadgeNumber = 0
        


    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.refreshView()
    }
    
    override func viewDidAppear(animated: Bool) {
        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        let authCheck = Authentication()
        authCheck.logout()
        authCheck.goToLoginVC(true)
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    // MARK: - Navigation
    @IBAction func unwindToTasksMain(segue:UIStoryboardSegue) {
        self.refreshView()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return taskList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell", forIndexPath: indexPath) as! UITableViewCell
        let task = taskList[indexPath.row]

        cell.textLabel!.text = task.taskDescription
        cell.detailTextLabel!.text = ("\(task.taskCreatorEmail) assigned this \(task.taskStatus) task on \(task.taskCreatedDateTime)")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete action
            
            
            let taskToDelete = self.taskList[indexPath.row]
            
            realm.write {self.realm.delete(taskToDelete)}
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    
}

