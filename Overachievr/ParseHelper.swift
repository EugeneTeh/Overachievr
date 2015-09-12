//
//  ParseHelper.swift
//  Overachievr
//
//  Created by Eugene Teh on 9/8/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    
    func getUserRelatedTasksQuery() -> PFQuery {
        let userDetails = Authentication().getUserDetails()
        
        var createdBySelf = PFQuery(className: "Task")
        createdBySelf.whereKey("taskCreatorEmail", equalTo: userDetails.email)
        
        var assignedToSelf = PFQuery(className: "Task")
        assignedToSelf.whereKey("taskAssignedSearch", equalTo: userDetails.email)
        
        var query = PFQuery.orQueryWithSubqueries([
            createdBySelf,
            assignedToSelf])
        query.orderByAscending("updatedAt")
        
        return query
    }
    
    func getUserRelatedTasksWithSpecifiedAssigneeQuery(assignees: NSArray) -> PFQuery {
        var query = PFQuery(className: "Task")
        let userDetails = Authentication().getUserDetails()
        query.whereKey("taskAssignedTo", containsAllObjectsInArray: assignees as [AnyObject])
        query.orderByAscending("updatedAt")
        
        return query
    }
    
    func removeDuplicateAssignees(array: [(groupName: String, description: String, assignees: NSArray)]) -> [(groupName: String, description: String, assignees: NSArray)] {
        var encountered = Set<String>()
        var result: [(groupName: String, description: String, assignees: NSArray)] = []
        for value in array {
            if !encountered.contains(value.description) {
                // Add value to the set.
                encountered.insert(value.description)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }
    
    func sendPushToTaskAssignee(assigneeEmail: String, message: String) {
        let userQuery = PFUser.query()
        userQuery!.whereKey("email", equalTo: assigneeEmail)
        
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", matchesQuery: userQuery!)
        
        let push = PFPush()
        let data = [
            "alert" : message,
            "badge" : "Increment",
            "sound" : "default"
        ]
        push.setQuery(pushQuery) // Set our Installation query
        push.setData(data)
        push.sendPushInBackground()
    }
    
    func subscribeToPushChannels(channels: [String]) {
        let currentInstallation = PFInstallation.currentInstallation()
        for channel in channels {
            currentInstallation.addUniqueObject(channel, forKey: "channels")
        }
        currentInstallation.saveEventually()
    }
    
    func unsubscribeToPushChannel(channel: String) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.removeObject(channel, forKey: "channels")
        currentInstallation.saveEventually()
    }
    
    func associateDeviceToUser() {
        let installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.saveEventually()
    }
}