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
//import Alamofire
//import SwiftyJSON


enum TaskStatus: String {
    case New = "New"
    case Assigned = "Assigned"
    case Rejected = "Rejected"
    case Completed = "Completed"
    case Verified = "Verified"
    case Archived = "Archived"
    case Redo = "Redo"
}

class TaskHelper {
    
    // generate TaskID
    var generateTaskID: String {
        let taskIDPart1 = NSDate().formattedDateTimeToString("yyyyMMddhhmmss")
        let taskIDPart2 = NSUUID().UUIDString
        return ("T\(taskIDPart1)-\(taskIDPart2)")
    }
    
    var generateTaskGroupID: String {
        let taskGroupIDPart1 = NSDate().formattedDateTimeToString("yyyyMMddhhmmss")
        let taskGroupIDPart2 = NSUUID().UUIDString
        return ("TG\(taskGroupIDPart1)-\(taskGroupIDPart2)")
    }
        
//    func getAssignedTask(taskID: String) {
//        Alamofire.request(.GET, "http://52.25.48.116:9000/api/tasks/\(taskID)").responseJSON { _, _, data, error in
//            if let anError = error {
//                println("error calling GET on /posts/1")
//                println(error)
//            } else if let tasks = data as? NSDictionary {
//                let realm = Realm()
//                realm.write {
//                    realm.create(Tasks.self, value: tasks, update: true)
//                }
//                let taskObject = realm.objects(Tasks).filter("taskID = '\(taskID)'")
//                if let taskCreator = taskObject[0].valueForKey("taskCreatorName") as? String {
//                    let app = UIApplication.sharedApplication()
//                    
//                    var notification = UILocalNotification()
//                    notification.alertBody = "\(taskCreator) assigned you a task"
//                    notification.applicationIconBadgeNumber++
//                    notification.soundName = UILocalNotificationDefaultSoundName 
//                    notification.alertTitle = "Test task"
//                    notification.fireDate = NSDate()
//                    
//                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
//                }
//                
//                
//
//            }
//        }
//    }
}

extension Object {
    func toDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValuesForKeys(properties)
        
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeysWithDictionary(dictionary)
        
        for prop in self.objectSchema.properties as [Property]! {
            // find lists
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
        return mutabledic
    }

}


