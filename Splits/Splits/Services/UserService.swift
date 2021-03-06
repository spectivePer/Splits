//
//  UserService.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import Foundation
import Firebase
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct UserService {
    // Database Read User Data from local cache (not always updated)
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
    // Read a single user from updated DB and update it as current user
    static func updateCurrentUser(user: User, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(user.uid)
        _ = ref.observe(DataEventType.value, with: { (snapshot) in
          let userDict = snapshot.value as? [String : AnyObject] ?? [:]
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }

            guard let username = userDict["username"] as? String, let name = userDict["name"] as? String, let num = userDict["phoneNumber"] as? String, let friends = userDict["friends"] as? [String:String] else {
                return completion(nil)
            }

            if let groups = userDict["groups"] as? [String] {
                let newUser = User(uid: user.uid, name: name, username: username, phoneNumber: num, groups: groups, friends: friends)
                newUser.friends = friends
                newUser.groups = groups
                completion(newUser)

            } else {
                let newUser = User(uid: user.uid, name: name, username: username, phoneNumber: num, groups: [], friends: friends)
                newUser.friends = friends
                completion(newUser)
            }
        })
    }

    // Grab snapshot of Users
    static func grabUsersSnapshot() -> [String: Any] {
        let ref = Database.database().reference().child("users")
        var retUsersSnapshot: [String: Any] = [:]
        _ = ref.observe(DataEventType.value, with: { (snapshot) in
          let usersSnapshot = snapshot.value as? [String : AnyObject] ?? [:]
            retUsersSnapshot = usersSnapshot
        })
        
        return retUsersSnapshot
    }

    // Database Create User
    static func create(_ firUser: FIRUser, name: String, username: String, phoneNumber: String, stripeId: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["name": name, "username": username, "phoneNumber": phoneNumber, "stripeId": stripeId]

        let ref = Database.database().reference().child("users").child(phoneNumber)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }

            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }

    // Database Create Non-User with PhoneNumber -> UID
    static func createNonUser(name: String, username: String, phoneNumber: String, stripeId: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["name": name, "username": username, "phoneNumber": phoneNumber, "stripeId": stripeId]

        let ref = Database.database().reference().child("users").child(phoneNumber)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                completion(nil)
            }

            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    static func addGroupIDToUsers(uid: String, groupName: String, users: [String: String]) {
        for (userID, userName) in users {
            let ref = Database.database().reference().child("users").child(userID)
            let updates = [
                "name": userName,
                "phoneNumber": userID,
                "/groups/\(uid)" : groupName
            ]
            ref.updateChildValues(updates)
        }
    }
}

