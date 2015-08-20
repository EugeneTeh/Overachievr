//
//  Tasks.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/5/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import Foundation
import RealmSwift

class Tasks: Object {
    
    dynamic var taskID: String = ""
    dynamic var taskCreatorName = ""
    dynamic var taskCreatorEmail: String = ""
    dynamic var taskName: String = ""
    dynamic var taskDescription: String = ""
    dynamic var taskStatus: String = ""
    dynamic var taskTip: Double = 0.0
    dynamic var taskDueDateTime: String = ""
    dynamic var taskReminderDateTime: String = ""
    
    let taskAssignedTo = List<TaskAssignee>()
    
    dynamic var taskCreatedDateTime: String = NSDate().formattedDateTimeToString("yyyy-MM-dd'T'HH:mm:ssz")
    dynamic var taskAssignedDateTime: String = ""
    dynamic var taskCompletedDateTime: String = ""
    dynamic var taskVerifiedDateTime: String = ""
    dynamic var taskArchivedDateTime: String = ""
    dynamic var taskRejectedDateTime: String = ""
    dynamic var taskRedoDateTime: String = ""
    
    override static func primaryKey() -> String {
        return "taskID"
    }
}


class TaskAssignee: Object {
    dynamic var assigneeEmail: String = ""
    dynamic var assigneeName: String = ""
    
    func taskAssigneeToDictionary() -> [String:AnyObject] {
        return [
            "assigneeEmail" : self.assigneeEmail,
            "assigneeName" : self.assigneeName
        ]
    }
}

extension Object {
    func toDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValuesForKeys(properties)
        
        var mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeysWithDictionary(dictionary)
        
        for prop in self.objectSchema.properties as [Property]! {
            // find lists
            if let objectClassName = prop.objectClassName  {
                if let nestedObject = self[prop.name] as? Object {
                    mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
                } else if let nestedListObject = self[prop.name] as? ListBase {
                    var objects = [AnyObject]()
                    for index in 0..<nestedListObject._rlmArray.count  {
                        if let object = nestedListObject._rlmArray[index] as? Object {
                            objects.append(object.toDictionary())
                        }
                    }
                    mutabledic.setObject(objects, forKey: prop.name)
                }
            }
        }
        return mutabledic
    }
}
