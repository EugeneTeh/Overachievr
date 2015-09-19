//
//  ContactsHelper.swift
//  Overachievr
//
//  Created by Eugene Teh on 9/17/15.
//  Copyright © 2015 Overachievr. All rights reserved.
//

import Contacts

@available(iOS 9.0, *)
class ContactsHelper {
    
    func getContacts() -> [CNContact] {
        let store = CNContactStore()
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactEmailAddressesKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        var contacts = [CNContact]()
        
        do {
            try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (let contact, let stop) -> Void in
                contacts.append(contact)
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        } 
        return contacts
    }
    
    func getFullName(contact: CNContact) -> String {
        if let fullName = CNContactFormatter.stringFromContact(contact, style: .FullName) {
            return fullName
        } else {
            return ""
        }
    }
    
}