//
//  CreateTaskVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/6/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire


class CreateTaskVC: UITableViewController, AssigneeSelectionDelegate  {
    
    
    @IBOutlet weak var assigneeCell: UITableViewCell!

    
    var assigneeSelected: Bool = false 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if assigneeSelected == false {
            
            let authentication = FacebookAuth()
            if authentication.getLoginSource() == LoginSource.Facebook.rawValue {
                assigneeCell.textLabel?.text = authentication.fbName
                assigneeCell.detailTextLabel?.text = authentication.fbEmail
            }
            
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //remove trailing unused cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: - Table view data source
    

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
println(segue.identifier)
        if segue.identifier == "unwindToTaskGroupsSegue" {
            
            
            let taskObject = Tasks()
            let taskHelper = TaskHelper()
            let assigneeObject = TaskAssignee()
            let realm = Realm()
            
            taskObject.taskID = taskHelper.generateID
            taskObject.taskCreatorEmail = taskHelper.getCreatorEmail
            taskObject.taskCreatorName = taskHelper.getCreatorName
            
            if let assigneeEmail = assigneeCell.detailTextLabel?.text,
                assigneeName = assigneeCell.textLabel?.text {
                assigneeObject.assigneeEmail = assigneeEmail
                assigneeObject.assigneeName = assigneeName
                taskObject.taskAssignedTo.append(assigneeObject)
            }
            
            taskObject.taskName = "Test Task \(realm.objects(Tasks).count + 1)"
            taskObject.taskDescription = "Test task description to understand display on iPhone screen if description is really long."
            taskObject.taskStatus = TaskStatus.New.rawValue
            
            
            realm.write {realm.add(taskObject)}

            let newTask = taskObject.toDictionary() as? [String : AnyObject]
            
            Alamofire.request(.POST, "http://52.25.48.116:9000/api/tasks/create", parameters: newTask, encoding: .JSON)

        }
        
    }
    
    
    


}
