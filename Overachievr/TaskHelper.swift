//
//  TaskHelper.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/6/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import RealmSwift
import Alamofire
import SwiftyJSON


enum TaskStatus: String {
    case New = "New"
    case Assigned = "Assigned"
    case Rejected = "Rejected"
    case Completed = "Completed"
    case Verified = "Verified"
    case Archived = "Archived"
}

class TaskHelper {
    
    // generate TaskID
    var generateID: String {
        let taskIDPart1 = NSDate().formattedDateTimeToString("yyyyMMddhhmmss")
        let taskIDPart2 = NSUUID().UUIDString
        return ("\(taskIDPart1)-\(taskIDPart2)")
    }

    var getCreatorEmail: String {
        if Authentication().getLoginSource() == LoginSource.Facebook.rawValue {
            return FacebookAuth().fbEmail
        } else {
            return ""
        }
        
    }
    
    var getCreatorName: String {
        if Authentication().getLoginSource() == LoginSource.Facebook.rawValue {
            return FacebookAuth().fbName
        } else {
            return ""
        }
        
    }
    
    
    
    func createNewTask(assigneeName: String, assigneeEmail: String) {
        
    }
    
    func getAssignedTask(taskID: String) {
        Alamofire.request(.GET, "http://52.25.48.116:9000/api/tasks/\(taskID)").responseJSON { _, _, data, error in
            if let anError = error {
                println("error calling GET on /posts/1")
                println(error)
            } else if let tasks = data as? NSDictionary {
                let realm = Realm()
                realm.write {
                    realm.create(Tasks.self, value: tasks, update: true)
                }
                let taskObject = realm.objects(Tasks).filter("taskID = '\(taskID)'")
                if let taskCreator = taskObject[0].valueForKey("taskCreatorName") as? String {
                    let app = UIApplication.sharedApplication()
                    
                    var notification = UILocalNotification()
                    notification.alertBody = "\(taskCreator) assigned you a task"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    notification.applicationIconBadgeNumber = app.applicationIconBadgeNumber + 1
                    notification.alertTitle = "Test task"
                    notification.fireDate = NSDate()
                    
                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                }
                
                

            }
        }
    }
}



