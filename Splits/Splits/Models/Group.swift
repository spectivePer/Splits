//
//  Group.swift
//  Splits
//
//  Created by Keith Choung on 2/28/21.
//

import FirebaseDatabase.FIRDataSnapshot

class Group: Codable {
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
    let users: [String:String]         // array of user IDs a part of this collection

    // MARK: - Init

    init(uid: String, groupName: String, users: [String]) {
        self.uid = uid
        self.groupName = groupName
        self.users = [:]
    }

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let groupName = dict["groupName"] as? String
            else { return nil }

        self.uid = snapshot.key
        self.groupName = groupName
        self.users = [:]
    }
}
