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
    
    // MARK: - Table view controls
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let uniqueSections = getUniqueSectionsWithTasks()
        let currentStatus = uniqueSections[indexPath.section].tasks[indexPath.row].valueForKey("taskStatus") as! String
        switch (currentStatus) {
        case TaskStatus.New.rawValue, TaskStatus.Completed.rawValue, TaskStatus.Redo.rawValue:
            return true
        default:
            return false
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let uniqueSections = getUniqueSectionsWithTasks()
        let currentStatus = uniqueSections[indexPath.section].tasks[indexPath.row].valueForKey("taskStatus") as! String
        
        switch (currentStatus) {
        case TaskStatus.New.rawValue, TaskStatus.Redo.rawValue:
            let rejectAction = UITableViewRowAction(style: .Default, title: "Reject", handler: {
                (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                
                tableView.setEditing(false, animated: true);
                self.updateCloudData(.Rejected, indexPath: indexPath, uniqueSections: uniqueSections)
                self.moveRowToSection(uniqueSections, sourceSection: .New, targetSection: .Rejected, indexPath: indexPath)
                
            })
            
            let completeAction = UITableViewRowAction(style: .Default, title: "Complete", handler: {
                (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                
                tableView.setEditing(false, animated: true);
                self.updateCloudData(.Completed, indexPath: indexPath, uniqueSections: uniqueSections)
                self.moveRowToSection(uniqueSections, sourceSection: .Redo, targetSection: .Completed, indexPath: indexPath)
                
            })
            completeAction.backgroundColor = UIColor(red: 132, green: 216, blue: 126)
            rejectAction.backgroundColor = UIColor.grayColor()
            
            return [completeAction, rejectAction]
            
        case TaskStatus.Completed.rawValue:
            let redoAction = UITableViewRowAction(style: .Default, title: "Redo", handler: {
                (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                
                tableView.setEditing(false, animated: true);
                self.updateCloudData(.Redo, indexPath: indexPath, uniqueSections: uniqueSections)
                self.moveRowToSection(uniqueSections, sourceSection: .Completed, targetSection: .Redo, indexPath: indexPath)
                
            })
            redoAction.backgroundColor = UIColor.grayColor()
            
            return [redoAction]
            
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func updateCloudData(status: TaskStatus, indexPath: NSIndexPath, uniqueSections: [(sectionName: String, tasks:[PFObject])]) {
        let currentObject = uniqueSections[indexPath.section].tasks[indexPath.row]
        
        currentObject.setValue(status.rawValue, forKey: "taskStatus")
        currentObject.pinInBackground()
        currentObject.saveEventually()
        self.tableView.reloadData()
        
    }
    
    func moveRowToSection(sectionsOrigin: [(sectionName: String, tasks:[PFObject])], sourceSection: TaskStatus, targetSection: TaskStatus, indexPath: NSIndexPath) {
        /*
        let sectionsNew = getUniqueSectionsWithTasks()
        
        tableView.beginUpdates()
        // If number of sections is more than before
        if sectionsOrigin.count < sectionsNew.count {
        tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        
        // If number of sections is less than before
        } else if sectionsOrigin.count > sectionsNew.count {
        tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        for section in sectionsNew {
        var sec = 0
        var path: [NSIndexPath] = []
        for var row=0; row<section.tasks.count; row++ {
        path += [NSIndexPath(forRow: row, inSection: sec)]
        }
        println(section.tasks.count)
        println(path.count)
        tableView.insertRowsAtIndexPaths(path, withRowAnimation: .None)
        }
        tableView.endUpdates()
        */
        
        tableView.reloadData()
        
        let currentObject = sectionsOrigin[indexPath.section].tasks[indexPath.row]
        
        let source = getIndexAndRows(currentObject, uniqueSections: getUniqueSectionsWithTasks())
        let target = getIndexAndRows(currentObject, uniqueSections: getUniqueSectionsWithTasks())
        
        tableView.beginUpdates()
        
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: source.rows , inSection: source.index!)], withRowAnimation: .Automatic)
        if(getUniqueSectionsWithTasks()[source.index!].tasks.count == 1){
            tableView.deleteSections(NSIndexSet(index: source.index!), withRowAnimation: .Automatic)
        }
        
        if(getUniqueSectionsWithTasks()[target.index!].tasks.count == 1){
            tableView.insertSections(NSIndexSet(index: target.index!), withRowAnimation: .Automatic)
        }
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: target.rows, inSection: target.index!)], withRowAnimation: .Automatic)
        
        tableView.endUpdates()
    }
    
    func migrateSection(sectionOrigins: [(sectionName: String, tasks:[PFObject])], sourceSectionIndex: Int, indexPath: NSIndexPath) {
        // move all unrelated from previous section to new section except for changed row
        var passedChangedRow = false
        for var i=0;i<sectionOrigins[sourceSectionIndex].tasks.count;i++ {
            // check if is row that changed
            if i == indexPath.row {
                passedChangedRow = true
            }
            
            let fromIndexPath = NSIndexPath(forRow: i, inSection: sourceSectionIndex)
            var toIndexPath = NSIndexPath(forRow: i, inSection: sourceSectionIndex + 1)
            
            // if iterated past row that was changed
            if passedChangedRow {
                toIndexPath = NSIndexPath(forRow: i-1, inSection: sourceSectionIndex + 1)
            }
            tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
        }
        // move changed row to newly inserted section
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func getIndexAndRows(object: PFObject, uniqueSections: [(sectionName: String, tasks:[PFObject])]) -> (index: Int?, rows: Int) {
        for var i=0;i<uniqueSections.count;i++ {
            for var j=0;j<uniqueSections[i].tasks.count;j++ {
                if object == uniqueSections[i].tasks[j] {
                    return (i,j)
                }
            }
        }
        return (0,0)
    }

    // MARK: - Table view data source
    
    override func queryForTable() -> PFQuery {
        let parseHelper = ParseHelper()
        return parseHelper.getUserRelatedTasksWithSpecifiedAssigneeQuery(assignees).fromLocalDatastore()
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let objects = objects {
            return getUniqueSectionsWithTasks().count
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = getUniqueSectionsWithTasks()
        return sections[section].sectionName
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = getUniqueSectionsWithTasks()
        return sections[section].tasks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("TaskCell") as! PFTableViewCell!
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TaskCell")
        }
    
        let section = getUniqueSectionsWithTasks()
        
        let taskDetails = section[indexPath.section].tasks[indexPath.row].valueForKey("taskDetails") as! String
        cell.textLabel?.text = taskDetails
        
        return cell
    }
    
    func getUniqueSectionsWithTasks() -> [(sectionName: String, tasks:[PFObject])] {
        if let objects = objects {
            var sections: [String] = []
            var tasks: [PFObject] = []
            var sectionsWithTasks: [(sectionName: String, tasks: [PFObject])] = []
            
            for eachTask in objects as NSArray {
                let status = eachTask.valueForKey("taskStatus") as! String
                sections.append(status)
            }
            
            //let uniqueSections = Array(Set(sections))
            let uniqueSections = unique(sections)
            for section in uniqueSections {
                for task in objects as NSArray {
                    if section == task.valueForKey("taskStatus") as! String {
                        tasks.append(task as! PFObject)
                    }
                }
                sectionsWithTasks += [(section, tasks)]
                tasks = []
            }
            return sectionsWithTasks
        } else {
            return []
        }
    }
    
    func unique<S: SequenceType, E: Hashable where E==S.Generator.Element>(source: S) -> [E] {
        var seen: [E:Bool] = [:]
        return filter(source) { seen.updateValue(true, forKey: $0) == nil }
    }

    
    // MARK: -  Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToTaskGroupsSegue" {
            let destinationVC = segue.destinationViewController as! TaskGroupsTVC
            destinationVC.getAssigneesFromLocalDatastore()
        }
    }

}
