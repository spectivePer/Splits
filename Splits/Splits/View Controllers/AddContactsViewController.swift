//
//  AddContactsViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 2/27/21.
//

import Foundation
import UIKit

class AddContactsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //TODO: selects contacts to add to split from table
    //TODO: recent/most splitting contacts at the top
    //TODO: user enter split name
    
    @IBAction func splitEvenlyButton(_ sender: Any) {
        displayEvenSplitView(vcName: "evenSplitView")
    }
    
    
    @IBAction func splitUnevenlyButton(_ sender: Any) {
        displayEvenSplitView(vcName: "unevenSplitView")
    }
    
    func displayEvenSplitView(vcName: String) {
        // handle new user
        let storyboard = UIStoryboard(name: "newSplit", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: vcName)
        // set the stack so that it only contains main and animate it
        let viewControllers = [vc]
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }

}
