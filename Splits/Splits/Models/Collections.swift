//
//  Collections.swift
//  Splits
//
//  Created by Keith Choung on 2/25/21.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class Collection: Codable {
    
    private static var _current: Collection?

    static var current: Collection {
        
        guard let currentCollection = _current else {
            fatalError("Error: current user doesn't exist")
        }

        return currentCollection
    }

    // MARK: - Class Methods
    
    static func invite(invitorID: String, invitees: [String], collection: Collection) {
        // Invitor invites all invitees to the current collection
    }
    
    static func removeUser(userIDToRemove: String, collection: Collection) {
        // Remove the user from the current collection
    }
    
    // MARK: - Properties

    let uid: String             // unique id of the collection
    let collectionName: String  // collection's name
    let users: [String]         // array of user IDs a part of this collection

    // MARK: - Init

    init(uid: String, collectionName: String, users: [String]) {
        self.uid = uid
        self.collectionName = collectionName
        self.users = [String]()
    }

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let collectionName = dict["username"] as? String
            else { return nil }

        self.uid = snapshot.key
        self.collectionName = collectionName
        self.users = [String]()
    }
}
