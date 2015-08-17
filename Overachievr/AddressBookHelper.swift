//
//  AddressBookHelper.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/9/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import Foundation
import AddressBook
import RealmSwift

protocol AssigneeSelectionDelegate {
    func didSelectAssignee(assigneeName: String, assigneeEmail: String)
}

class AddressBook {
    func getAddressBookNames() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        if (authorizationStatus == ABAuthorizationStatus.NotDetermined)
        {
            NSLog("requesting access...")
            var emptyDictionary: CFDictionaryRef?
            var addressBook = !(ABAddressBookCreateWithOptions(emptyDictionary, nil) != nil)
            ABAddressBookRequestAccessWithCompletion(addressBook,{success, error in
                if success {
                    self.processContactNames()
                }
                else {
                    NSLog("unable to request access")
                }
            })
        }
        else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            NSLog("access denied")
            
        }
        else if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            //NSLog("access granted")
            processContactNames()
        }
    }
    
    func processContactNames() {
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        
        for record:ABRecordRef in contactList {
            getContact(record)
            
            
        }
    }
    
    func getContact(addressBookRecord: ABRecordRef) {
        let realm = Realm()
        
        
        let emailArray:ABMultiValueRef = extractABEmailRef(ABRecordCopyValue(addressBookRecord, kABPersonEmailProperty))!
        
        for (var j = 0; j < ABMultiValueGetCount(emailArray); ++j) {
            var emailAdd = ABMultiValueCopyValueAtIndex(emailArray, j)
            var email = extractABEmailAddress(emailAdd)
            
            // check email validity
            if email?.rangeOfString("@") != nil {
                let contactObject = Contacts()
                let name = getContactName(addressBookRecord)
                
                let contactExists = realm.objects(Contacts).filter("contactEmail = '\(email!)'").count
                println(contactExists)

                
                if contactExists < 1 {

                    contactObject.contactEmail = email!
                    contactObject.contactName = name
                    
                    realm.write {realm.add(contactObject)}
                }

            }
            
        }
    }
    
    func getContactName(addressBookRecord: ABRecordRef) -> String {
        //NSLog("contactName: \(contactName)")
        return ABRecordCopyCompositeName(addressBookRecord).takeRetainedValue() as String
    }
    

    
    func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func extractABEmailRef (abEmailRef: Unmanaged<ABMultiValueRef>!) -> ABMultiValueRef? {
        if let ab = abEmailRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    func extractABEmailAddress (abEmailAddress: Unmanaged<AnyObject>!) -> String? {
        if let ab = abEmailAddress {
            return Unmanaged.fromOpaque(abEmailAddress.toOpaque()).takeUnretainedValue() as CFStringRef as String
        }
        return nil
    }
}