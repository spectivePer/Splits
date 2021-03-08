//
//  AddItemViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 2/27/21.
//

import Foundation
import UIKit

class AddItemViewController:UIViewController {
    @IBOutlet weak var itemDescription: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: (view), action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //TODO: User select participant(s)
    
    @IBAction func cancelItem(_ sender: Any) {
        displayViewController(storyboard: "newSplit", vcName: "unevenSplitView")
    }
    
    //TODO: Add item to unevenSplit vc table
    @IBAction func addItemButton(_ sender: Any) {
        var previousVC: UIViewController
        // get all the viewControllers to start with
        if let controllers = self.navigationController?.viewControllers {
            // iterate through all the viewControllers
            for (index, controller) in controllers.enumerated() {
                // when you find your current viewController
                if controller == self {
                    // then you can get index - 1 in the viewControllers array to get the previous one
                    previousVC = controllers[index-1]
                }
            }
        }
        
        let updateVC = previousVC as! UnevenSplitViewController
        
        guard let description = itemDescription.text else { return }
        guard let price = itemPrice.text else { return }
        print("\(description), \(price)")
    
        updateVC.tableContents.items.append(contentsOf: [(description, price)])
    
        guard let table = updateVC.receiptContentsTable else {
            print("no table")
            return
        }
        
        table.beginUpdates()
        table.insertRows(at: [IndexPath(row: updateVC.tableContents.items.count-1, section: 0)], with: .automatic)
        table.endUpdates()
        
        
        displayViewController(storyboard: "newSplit", vcName: "unevenSplitView")
    }
    
    func displayViewController(storyboard: String, vcName: String) {
            // handle new user
            let sb = UIStoryboard(name: storyboard, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
}
