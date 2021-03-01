//
//  UserService.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import Foundation
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

            guard let username = userDict["username"] as? String, let num = userDict["phoneNumber"] as? String, let friends = userDict["friends"] as? [String:String] else {
                return completion(nil)
            }
            

            if let groups = userDict["groups"] as? [String] {
                let newUser = User(uid: user.uid, username: username, phoneNumber: num, groups: groups, friends: friends)
                newUser.friends = friends
                newUser.groups = groups
                completion(newUser)

            } else {
                print(friends)
                let newUser = User(uid: user.uid, username: username, phoneNumber: num, groups: [], friends: friends)
                newUser.friends = friends
                completion(newUser)
            }
        })
    }
    
    // Database Create User
    static func create(_ firUser: FIRUser, username: String, phoneNumber: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["username": username, "phoneNumber": phoneNumber]
        let ref = Database.database().reference().child("users").child(firUser.uid)
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
}

