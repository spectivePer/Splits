//
//  User.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

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
    // MARK: - Properties

    let uid: String
    let username: String

    // MARK: - Init

    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
    }

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String
            else { return nil }

        self.uid = snapshot.key
        self.username = username
    }
}
