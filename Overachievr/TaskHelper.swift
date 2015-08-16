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
            return FacebookAuth().getFBNSUserDefaults().fbEmail
        } else {
            return ""
        }
        
    }
    
    var getCreatorName: String {
        if Authentication().getLoginSource() == LoginSource.Facebook.rawValue {
            return FacebookAuth().getFBNSUserDefaults().fbName
        } else {
            return ""
        }
        
    }
    
    
    
    func createNewTask(assigneeName: String, assigneeEmail: String) {
        
    }
}



