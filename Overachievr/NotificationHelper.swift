//
//  NotificationHelper.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/20/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import Foundation
import UIKit

class Notification {
    
    let app = UIApplication.sharedApplication()
    let alert = UILocalNotification()

    func clearOldNotifications() {
        let oldNotifications = app.scheduledLocalNotifications
        if oldNotifications.count > 0 {
            app.cancelAllLocalNotifications()
        }
    }
    
    func setLocalNotification(alertBody: String, badgeCount: Int) {
        self.alert.alertBody = alertBody
        //self.alert.applicationIconBadgeNumber = setAlertBadge(true, currentBadgeCount: <#Int#>, valueDelta: <#Int#>)
    }
    
    func setAlertBadge(increment: Bool, currentBadgeCount: Int, valueDelta: Int) -> Int {
        if increment {
            return currentBadgeCount + valueDelta
        } else {
            if currentBadgeCount - valueDelta < 0 {
                return 0
            } else {
                return currentBadgeCount - valueDelta
            }
            
        }
        
    }
    
}