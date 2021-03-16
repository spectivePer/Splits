//
//  GroupService.swift
//  Splits
//
//  Created by Keith Choung on 2/28/21.
//

import Foundation
import FirebaseDatabase

struct SplitService {
    // Database Create Collection
    static func createSplit(recipient: User, splitName: String, users: [String:String], completion: @escaping (Split?, String, [String:String]) -> Void) {   // takes in an array of user IDs to add
        let uuid = UUID().uuidString
        print(uuid)
        let recipientInfo = [recipient.uid: recipient.name]
        var usersWithRecipient = users
        usersWithRecipient[recipient.uid] = recipient.name
        let ref = Database.database().reference().child("splits").child(uuid)
        let splitAttrs = ["name": splitName, "users": usersWithRecipient, "recipient": recipientInfo] as [String : Any]

        ref.setValue(splitAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil, "", users)
            }

            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let split = Split(snapshot: snapshot)
                completion(split, uuid, usersWithRecipient)
            })
        }
    }
    
    static func createEqualSplit(totalAmount: Double, evenSplitAmount: Double, splitUid: String, recipient: User) {
        let ref = Database.database().reference().child("splits").child(splitUid)
        print("Updating DB with new Split")
        let splitUpdates = [
            "totalAmount" : totalAmount,
            "evenSplitAmount" : evenSplitAmount,
            "recipient" : recipient.uid
        ] as [String : Any]
        
        ref.updateChildValues(splitUpdates)
    }

    static func updateUserSplitIDs(user: User) {
        let ref = Database.database().reference().child(user.uid).child("splits")
        ref.observe(.childAdded, with: { (snapshot) -> Void in
            guard let splits = snapshot.value as? [String:String] else {
                return
            }
            
            for (splitID, splitName) in splits {
                user.splits[splitID] = splitName
            }
        })
    }

    static func updateUserSplit(splitIds: String, completion: @escaping (Split?) -> Void) {
        let ref = Database.database().reference().child("splits").child(splitIds)
        ref.observe(DataEventType.value, with: { (snapshot) in
            guard let split = Split(snapshot: snapshot) else {
                return completion(nil)
            }
            
            return completion(split)
        })
    }
}
