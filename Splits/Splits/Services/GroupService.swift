//
//  GroupService.swift
//  Splits
//
//  Created by Keith Choung on 2/28/21.
//

import Foundation
import FirebaseDatabase

struct GroupService {
    // Database Create Collection
    static func createGroup(groupName: String, users: [String:String], completion: @escaping (Group?, String) -> Void) {   // takes in an array of user IDs to add
        let uuid = UUID().uuidString
        print(uuid)
        let ref = Database.database().reference().child("groups").child(uuid)
        let groupAttrs = ["name": groupName, "users": users] as [String : Any]

        ref.setValue(groupAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil, "")
            }

            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let group = Group(snapshot: snapshot)
                completion(group, uuid)
            })
        }
    }
}
