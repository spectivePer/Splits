//
//  User.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import FirebaseAuth
import SwiftyContacts


class User: Codable {
    // MARK: - Singleton

    private static var _current: User?

    static var current: User {
        
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }

        return currentUser
    }

    // MARK: - Class Methods

    static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
            if writeToUserDefaults {
                
                if let data = try? JSONEncoder().encode(user) {
                    
                    UserDefaults.standard.set(data, forKey: "currentUser")
                }
            }

        _current = user
    }
    
    static func removeCurrent(_ user: User) {
            
        UserDefaults.standard.removeObject(forKey: "currentUser")
        _current = User(uid: "", name: "", username: "", phoneNumber: "", stripeId: "", splits: [:])
    }
    
    
    // Methods for importing contacts
    
    static func requestUserToAccessContacts() -> Bool {
        var returnStatus = false

        requestAccess { (resp) in
            if resp {
                print("Contacts Access Granted")
                returnStatus = true
            } else {
                print("Contacts Access Denied")
                returnStatus = false
            }
        }
        
        return returnStatus
    }

    static func checkContactsPermissions() -> Bool {
        var isAuthorized = false
        
        authorizationStatus { (status) in
            switch status {
                case .authorized:
                    print("authorized")
                    isAuthorized = true
                    break
                case .denied:
                    print("denied")
                    isAuthorized = false
                    break
                default:
                    break
            }
        }
        return isAuthorized
    }
    
    static func grabContacts(user: User) -> [String: String] {
        var retContacts: [String: String] = [:]
        
        fetchContacts { (result) in
            switch result {
                case .success(let contacts):
                    retContacts = assignContactsAsFriends(contacts: contacts, user: user)
                    break
                case .failure(let error):
                    print("error: ", error)
                    break
            }
        }
        return retContacts
    }

    static func assignContactsAsFriends(contacts: [CNContact], user: User) -> [String: String] {
        // Grab a snapshot of Users in the DB
        // Cross Check if the phone number is in the DB
        // UserService.grabUsersSnapshot()
        var retContacts: [String: String] = [:]
        
        for contact in contacts {
            let contactFirstName = (contact.givenName)
            let contactLastName = (contact.familyName)
            if !contact.phoneNumbers.isEmpty {
                if let contactPhoneNumber =  (contact.phoneNumbers[0].value).value(forKey: "digits") as? String {
                let contactFullName = contactFirstName + " " + contactLastName
                retContacts[contactPhoneNumber] = contactFullName
            }
            }
        }
        return retContacts
    }

    // MARK: - Properties

    let uid: String                 // unique id
    let name: String                // user's name
    var username: String            // user's name
    let stripeId: String            // user's stripe id
    var phoneNumber: String         // user's phone number
    var splits: [String:String]            // array of splits IDs the user is a part of

    // MARK: - Init

    init(uid: String, name: String, username: String, phoneNumber: String, stripeId:String, splits: [String:String]) {
        self.uid = uid
        self.name = name
        self.username = username
        self.phoneNumber = ""
        self.splits = [:]
        self.stripeId = ""

    }

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
              let stripeId = dict["stripeId"] as? String,
              let username = dict["username"] as? String,
              let phoneNumber = dict["phoneNumber"] as? String,
              let name = dict["name"] as? String
        else { return nil }
            
        self.uid = snapshot.key
        self.name = name
        self.username = username
        self.stripeId = stripeId
        self.phoneNumber = phoneNumber
        self.splits = [:]
    }
}
