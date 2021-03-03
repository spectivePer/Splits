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
        displayView(vcName: "addItemView")
    }
    
    @IBAction func previousView(_ sender: Any) {
        displayView(vcName: "addContactsView")
    }
    
    //TODO: Add split name from addContacts vc
    //TODO: Add participants from addContacts vc
    //TODO: table view of item description, price, and assigned participant
    //TODO: Link camera button
    //TODO: Link create split to payment
    
    func displayView(vcName: String) {
            // handle new user
            let storyboard = UIStoryboard(name: "newSplit", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
}
