//
//  CollectionService.swift
//  Splits
//
//  Created by Keith Choung on 2/25/21.
//
import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct GroupService {
    // Database Create Collection
    static func createGroup(users: [String], completion: @escaping (Group?) -> Void) {   // takes in an array of user IDs to add
        let uuid = UUID().uuidString
        print(uuid)
        let ref = Database.database().reference().child("collections").child(uuid)
        
        let groupAttrs = ["users": users]
        
        ref.setValue(groupAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }

            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let group = Group(snapshot: snapshot)
                completion(group)
            })
        }
    }
}
