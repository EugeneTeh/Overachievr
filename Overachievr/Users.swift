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
    dynamic var userPrimaryEmail: String = ""
    dynamic var userMobile: String = ""
    dynamic var userFBEmail: String = ""
    dynamic var userFBFirstName: String = ""
    dynamic var userFBLastName: String = ""
    dynamic var userFBName: String = ""
    dynamic var userFBToken: String = ""
    dynamic var userFBID: String = ""
    dynamic var userGMail: String = ""
    dynamic var userGMailToken: String = ""
    dynamic var userIsRegistered: Bool = false
    dynamic var userRegisteredDateTime: String = ""
    dynamic var userLastSessionDateTime: String = ""
    dynamic var userSessionID: String = ""
    dynamic var userAPNSToken: String = ""
    dynamic var userAuthSource: String = ""

}