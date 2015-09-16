//
//  Users.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/18/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import Foundation
import RealmSwift

class Users: Object {
    dynamic var userEmail: String = ""
    dynamic var userFirstName: String = ""
    dynamic var userLastName: String = ""
    dynamic var userGoogleToken: String = ""
    dynamic var userFacebookToken: String = ""
    dynamic var userFacebookID: String = ""
    dynamic var userPicURL: String = ""
    dynamic var userRegisteredDateTime: String = ""
    dynamic var userLastSessionDateTime: String = ""
    dynamic var userSessionID: String = ""
    dynamic var userAPNSToken: String = ""
    dynamic var userAuthSource: String = ""
//    dynamic var userLinkedEmails = List<LinkedEmails>()
    
    
    override static func primaryKey() -> String {
        return "userEmail"
    }

}


class LinkedEmails: Object {
    dynamic var linkedEmail: String = ""
}
