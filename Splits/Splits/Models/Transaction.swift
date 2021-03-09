//
//  Transaction.swift
//  Splits
//
//  Created by Keith Choung on 2/28/21.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class Transaction: Codable {
    // MARK: - Class Methods
    // TODO ....
    
    // MARK: - Properties

    let groupName: String                   // group's name
    let groupID: String                     // group's uid
    let recipient: String                   // array of user IDs a part of this collection
    let status: Int                         // 0 -> Pending Payment | 1 -> Need to Pay Recipient | 2 -> Complete
    let participantMap: [String: String]    // uid       -> user's name
    let userItemMap: [String: String]       // uid       -> item name
    let itemPriceMap: [String: Double]      // item name -> price
    let totalAmount : Double                // Total amount  $30
    let equalAmount: Double                 // $10
    let isEqual: Bool                       // false -> Itemized | true -> Equal
    
    // MARK: - Init

//    init(uid: String, groupName: String, users: [String]) {
//        self.uid = uid
//        self.groupName = groupName
//        self.users = [String]()
//    }
//
//    init?(snapshot: DataSnapshot) {
//        guard let dict = snapshot.value as? [String : Any],
//            let groupName = dict["groupName"] as? String
//            else { return nil }
//
//        self.uid = snapshot.key
//        self.groupName = groupName
//        self.users = [String]()
//    }
}
