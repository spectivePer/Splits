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
    // Database Read User Data
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    // Database Create User
    static func create(_ firUser: FIRUser, username: String, phoneNumber: String, stripeId: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["username": username, "phoneNumber": phoneNumber, "stripeId": stripeId]

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

