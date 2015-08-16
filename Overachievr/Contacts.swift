//
//  Contacts.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/10/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import Foundation

import RealmSwift

class Contacts: Object {
    dynamic var contactEmail: String = ""
    dynamic var contactName: String = ""
    
    override static func primaryKey() -> String {
        return "contactEmail"
    }
    
}