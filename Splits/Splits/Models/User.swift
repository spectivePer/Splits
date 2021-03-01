//
//  User.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import FirebaseAuth

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
        _current = User(uid: "", name: "", username: "", phoneNumber: "", groups: [""], friends: ["":""])
    }
    
    // MARK: - Properties

    let uid: String           // unique id
    let name: String          // user's name
    var username: String      // user's name
    var phoneNumber: String   // user's phone number
    var groups: [String] // array of collection IDs the user is a part of
    var friends: [String: String] // Dictionary of friends' names to friends' UID


    // MARK: - Init

    init(uid: String, name: String, username: String, phoneNumber: String, groups: [String], friends: [String:String]) {
        self.uid = uid
        self.name = name
        self.username = username
        self.phoneNumber = "+14157777777"  // Default until we add phone number capability
        self.groups = [String]()
        self.friends = [String: String]()
    }

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
              let username = dict["username"] as? String,
              let name = dict["name"] as? String
        else { return nil }
            
        self.uid = snapshot.key
        self.name = name
        self.username = username
        self.phoneNumber = "+14157777777" // Default until we add phone number capability
        self.groups = [String]()
        self.friends = [String: String]()

    }
}
