//
//  ItemTableModelController.swift
//  Splits
//
//  Created by Jocelyn Park on 3/5/21.
//

import Foundation
import UIKit

class ItemTableModelController {
    typealias itemInfo = (price: String, description: String)
    struct ReceiptContents {
        var items = [itemInfo]()
    }
    
    var tableContents = ReceiptContents()
    
    private var ReceiptContents: ReceiptContents
    init(receiptContents: ReceiptContents) {
        self.ReceiptContents = receiptContents
    }
    
    func addItem(tableView: UITableView, newItem: itemInfo) {
        
        tableContents.items.append(contentsOf: [newItem])
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: tableContents.items.count-1, section: 0)], with: .automatic)
        tableView.endUpdates()
        
        
        print("added \(newItem.description), \(newItem.price)")
    }
}
/*
extension ItemTableModelController {
    func addItem(tableView: UITableView, newItem: itemInfo) {
        
        tableContents.items.append(contentsOf: [newItem])
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: tableContents.items.count-1, section: 0)], with: .automatic)
        tableView.endUpdates()
        
        
        print("added \(newItem.description), \(newItem.price)")
    }
}
*/
