//
//  CollaboratorTVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/27/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import RealmSwift

class CollaboratorTVC: UITableViewController {
    
    var collaboratorTaskList = Realm().objects(Tasks)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func didSelectGroup(groupDetails: (groupName: String, description: String, emails: [String])) {
        //collaboratorTaskList = Realm().objects(Tasks).filter("ANY taskAssignedTo.assigneeEmail = '\(groupID)'")
        self.title = groupDetails.groupName
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
        return collaboratorTaskList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        let task = collaboratorTaskList[indexPath.row]
        
        cell.textLabel?.text = task.taskDescription
        cell.detailTextLabel?.text = "\(task.taskCreatorName) assigned this to \(task.taskAssignedTo[0].assigneeName)"

        return cell
    }

}
