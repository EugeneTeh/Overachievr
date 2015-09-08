//
//  CreateTaskVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/6/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import Parse
import RealmSwift
import Alamofire


class CreateTaskVC: UITableViewController, UITextViewDelegate, AssigneeSelectionDelegate  {
    
    
    @IBOutlet weak var assigneeCell: UITableViewCell!
    @IBOutlet weak var taskDetailsTextView: UITextView!
    
    let placeholderText = "What would you like done?"
    var taskDetailsString: String {
        get {
            return taskDetailsTextView.text
        }
        set {
            taskDetailsTextView.text = newValue
            
            textViewDidChange(taskDetailsTextView)
        }
    }
    var assigneeSelected: Bool = false 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskDetailsTextView.delegate = self
        
        if assigneeSelected == false {
            let userDetails = Authentication().getUserDetails()
            assigneeCell.textLabel?.text = userDetails.name
            assigneeCell.detailTextLabel?.text = userDetails.email
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

            self.taskDetailsTextView.text = placeholderText
            self.taskDetailsTextView.textColor = UIColor.lightGrayColor()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
// MARK: - TextView controls
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        self.taskDetailsTextView.textColor = UIColor.blackColor()
        
        if(self.taskDetailsTextView.text == placeholderText) {
            self.taskDetailsTextView.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(taskDetailsTextView.text == "") {
            self.taskDetailsTextView.text = placeholderText
            self.taskDetailsTextView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
        
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    

// MARK: - Actions
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "assignToCell" {
            self.performSegueWithIdentifier("showContacts", sender: self)
        }
        
    }
    
    func didSelectAssignee(assigneeName: String, assigneeEmail: String) {
        assigneeSelected = true
        assigneeCell.textLabel?.text = assigneeName
        assigneeCell.detailTextLabel?.text = assigneeEmail
    }
    
    func getAssigneeDetails() -> (name: String, email: String) {
        var name = ""
        var email = ""
        if let assigneeName = assigneeCell.textLabel?.text {
            name = assigneeName
        }
        if let assigneeEmail = assigneeCell.detailTextLabel?.text {
            email = assigneeEmail
        }
        
        return (name, email)
    }
    
    func doesTaskGroupExistQuery(groupID: String) -> PFQuery {
        var query = PFQuery(className: "TaskGroup")
        query.whereKey("groupID", equalTo: groupID)
        
        return query
    }
    
// MARK: - Display Controls
    
    // Disable save button until text is entered in task title
    /*
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let length = count(textField.text) - range.length + count(string)
        if length > 0 {
            
        } else {
            
        }
        return true
    }
    */
    
    
// MARK: - Navigation
    
    @IBAction func unwindToCreateTask(segue:UIStoryboardSegue) {
        
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToTaskGroupsSegue" {
            
            let task = PFObject(className: "Task")
            let taskGroup = PFObject(className: "TaskGroup")
            let userDetails = Authentication().getUserDetails()
            let assignees = getAssigneeDetails()
            
            
            task["taskID"] = TaskHelper().generateTaskID
            task["taskDetails"] = taskDetailsTextView.text
            task["taskCreatorName"] = userDetails.name
            task["taskCreatorEmail"] = userDetails.email
            task["taskStatus"] = TaskStatus.New.rawValue
            
            if assigneeCell.detailTextLabel?.text != userDetails.email {
                task["taskAssignedDateTime"] = NSDate()
            }
            
            task["taskAssignedTo"] = [["name": assignees.name, "email": assignees.email]]
            
            task.pinInBackground()
            task.saveEventually()

        }
        
    }
}
