//
//  AddItemViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 2/27/21.
//

import Foundation
import UIKit

class AddItemViewController:UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
    //TODO: User input item name
    //TODO: User input price
    //TODO: User select participant(s)
    
    @IBAction func cancelItem(_ sender: Any) {
        displayView(vcName: "unevenSplitView")
    }
    
    //TODO: Add item to unevenSplit vc table
    @IBAction func addItemButton(_ sender: Any) {
        displayView(vcName: "unevenSplitView")
    }
    
    
    func displayView(vcName: String) {
            // handle new user
            let storyboard = UIStoryboard(name: "newSplit", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
}
