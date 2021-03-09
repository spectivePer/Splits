//
//  Group.swift
//  Splits
//
//  Created by Keith Choung on 2/28/21.
//

import FirebaseDatabase.FIRDataSnapshot

class Split: Codable {
    // MARK: - Class Methods
    
    static func invite(invitorID: String, invitees: [String], split: Split) {
        // Invitor invites all invitees to the current collection
    }

    static func updateUserSplits(uid: String) {
        
    }

    // MARK: - Properties

    let uid: String?                     // unique id of the collection
    let splitName: String?               // collection's name
    let users: [String:String]?          // array of user IDs a part of this split
    let recipient: String?                   // array of user IDs a part of this collection
    let statusMap: [String:Int]?                         // 0 -> Pending Payment | 1 -> Need to Pay Recipient | 2 -> Complete
    let userItemMap: [String: String]?       // uid       -> item name
    let itemPriceMap: [String: Double]?      // item name -> price
    let totalAmount : Double?                // Total amount  $30
    let equalAmount: Double?                 // $10
    let isEqual: Bool?                       // false -> Itemized | true -> Equal

    // MARK: - Init

    init(uid: String? = nil, splitName: String? = nil,
         users: [String:String]? = nil, recipient: String? = nil, statusMap: [String:Int]? = nil, userItemMap: [String:String]? = nil, itemPriceMap: [String:Double]? = nil,  totalAmount : Double? = 0.0, equalAmount: Double? = 0.0, isEqual: Bool? = true) {
        self.uid = uid
        self.splitName = splitName
        self.users = users
        self.recipient = recipient
        self.statusMap = statusMap
        self.userItemMap = userItemMap
        self.itemPriceMap = itemPriceMap
        self.totalAmount = totalAmount
        self.equalAmount = equalAmount
        self.isEqual = isEqual
    }

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let splitName = dict["splitName"] as? String,
            let recipient = dict["recipient"] as? String,
            let statusMap = dict["statusMap"] as? [String:Int],
            let userItemMap = dict["userItemMap"] as? [String: String],
            let itemPriceMap = dict["itemPriceMap"] as? [String: Double],
            let totalAmount = dict["totalAmount"] as? Double,
            let equalAmount = dict["equalAmount"] as? Double,
            let isEqual = dict["isEqual"] as? Bool
            else { return nil }

        self.uid = snapshot.key
        self.splitName = splitName
        self.users = [:]
        self.recipient = recipient
        self.statusMap = statusMap
        self.userItemMap = userItemMap
        self.itemPriceMap = itemPriceMap
        self.totalAmount = totalAmount
        self.equalAmount = equalAmount
        self.isEqual = isEqual
    }
}
