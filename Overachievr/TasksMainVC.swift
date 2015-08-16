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

class TasksMainVC: UITableViewController {
    
    let taskList = Realm().objects(Tasks).sorted("taskCreatedDateTime", ascending: false)
    let realm = Realm()
    var tempCounter = 1

    override func viewDidLoad() {
        super.viewDidLoad()
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
        authCheck.resetLogin()
        authCheck.goToLoginVC()
    }
    
    
    @IBAction func unwindToTasksMain(segue:UIStoryboardSegue) {
        self.tableView.reloadData()

    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "createDetailedTask" {
            
        }
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

        cell.textLabel!.text = task.taskName
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

