//
//  UnevenSplitViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 2/27/21.
//

import Foundation
import UIKit

class UnevenSplitViewController:UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        displayView(storyboard: "newSplit", vcName: "addItemView")
    }
    
    @IBAction func previousView(_ sender: Any) {
        displayView(storyboard: "newSplit", vcName: "addContactsView")
    }
    
    @IBAction func scanReceipt(_ sender: Any) {
        displayView(storyboard: "newSplit", vcName: "scanReceiptView")
    }
    
    
    //TODO: Add split name from addContacts vc
    //TODO: Add participants from addContacts vc
    //TODO: table view of item description, price, and assigned participant
    //TODO: Link camera button
    //TODO: Link create split to payment
    
    func displayView(storyboard: String, vcName: String) {
            // handle new user
            let sb = UIStoryboard(name: storyboard, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
}
