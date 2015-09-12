//
//  CreateTaskVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/6/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import Parse

class CreateTaskVC: UITableViewController, UITextViewDelegate, AssigneeSelectionDelegate  {
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
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
    var assigneeSelected: Bool = false {
        didSet {
            let assigneeDetails = getAssigneeDetails()
            let userDetails = Authentication().getUserDetails()
            if assigneeSelected && assigneeDetails.email != userDetails.email {
                saveButton.title = "Send"
            } else {
                saveButton.title = "Save"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.enabled = false
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
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        let task = PFObject(className: "Task")
        let taskGroup = PFObject(className: "TaskGroup")
        let userDetails = Authentication().getUserDetails()
        let assignees = getAssigneeDetails()
        
        task["taskID"] = TaskHelper().generateTaskID
        task["taskDetails"] = taskDetailsTextView.text
        task["taskCreatorName"] = userDetails.name
        task["taskCreatorEmail"] = userDetails.email
        task["taskAssignedSearch"] = [assignees.email]
        task["taskStatus"] = TaskStatus.New.rawValue
        
        if assigneeCell.detailTextLabel?.text != userDetails.email {
            task["taskAssignedDateTime"] = NSDate()
        }
        
        task["taskAssignedTo"] = [["name": assignees.name, "email": assignees.email]]
        task.saveEventually()
        task.pinInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if success {
                if userDetails.email != assignees.email {
                    ParseHelper().sendPushToTaskAssignee(assignees.email, message: "\(userDetails.name) has assigned you \"\(self.taskDetailsTextView.text)\"")
                }
                self.performSegueWithIdentifier("unwindToTaskGroupsSegue", sender: nil)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "assignToCell" {
            self.performSegueWithIdentifier("showContacts", sender: self)
        }
        
    }
    
    func didSelectAssignee(assigneeName: String, assigneeEmail: String) {
        assigneeCell.textLabel?.text = assigneeName
        assigneeCell.detailTextLabel?.text = assigneeEmail
        assigneeSelected = true
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

    
// MARK: - Display Controls
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let length = count(textView.text) - range.length + count(text)
        if length > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
        return true
    }
    
    
// MARK: - Navigation
    
    @IBAction func unwindToCreateTask(segue:UIStoryboardSegue) {
        
    }
}
