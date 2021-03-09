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
                print("Could not grab user")
                return completion(nil)
            }
            print("userDict: ",userDict)
            guard let name = userDict["name"] as? String,
                  let num = userDict["phoneNumber"] as? String,
                  let splits = userDict["splits"] as? [String:String]
            else {
                print("couldn't grab | name| num | splits")
                return completion(nil)
            }
            
            let newUser = User(uid: user.uid, name: name, username: name, phoneNumber: num, stripeId: "", splits: splits)
            newUser.splits = splits
            completion(newUser)
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
    
    static func addGroupIDToUsers(uid: String, splitName: String, users: [String: String]) {
        for (userID, userName) in users {
            let ref = Database.database().reference().child("users").child(userID)
            let updates = [
                "name": userName,
                "phoneNumber": userID,
                "/splits/\(uid)" : splitName
            ]
            ref.updateChildValues(updates)
        }
    }
}

