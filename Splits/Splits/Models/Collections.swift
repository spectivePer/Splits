//
//  Collections.swift
//  Splits
//
//  Created by Keith Choung on 2/25/21.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class Group: Codable {
    
    private static var _current: Group?

    static var current: Group {
        
        guard let currentCollection = _current else {
            fatalError("Error: current user doesn't exist")
        }

        return currentCollection
    }

    // MARK: - Class Methods
    
    static func invite(invitorID: String, invitees: [String], group: Group) {
        // Invitor invites all invitees to the current collection
    }

    static func removeUser(userIDToRemove: String, group: Group) {
        // Remove the user from the current collection
    }
    
    // MARK: - Properties

    let uid: String             // unique id of the collection
    let groupName: String  // collection's name
    let users: [String]         // array of user IDs a part of this collection

    // MARK: - Init

    init(uid: String, groupName: String, users: [String]) {
        self.uid = uid
        self.groupName = groupName
        self.users = [String]()
    }

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let groupName = dict["groupName"] as? String
            else { return nil }

        self.uid = snapshot.key
        self.groupName = groupName
        self.users = [String]()
    }
}