//
//  CollectionService.swift
//  Splits
//
//  Created by Keith Choung on 2/25/21.
//
import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct CollectionService {
    // Database Create Collection
    static func createCollection(members: [String]) {
        
        // get the ref: somehow with a uid?
        // let ref = Database.database().reference().child("collections").child()
        
        // add members to the collection
        
        // let collectionAttrs = [{"username": username, "phoneNumber": phoneNumber, "collections": emptyCollections] as [String : Any]
        
        // then use set value to add to the db.
        // ref.setValue()...
    }
}
