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

        // Do any additional setup after loading the view.
                
    }
    @IBAction func splitEvenlyButton(_ sender: Any) {
        displayEvenSplitView()
    }
    
    func displayEvenSplitView() {
        // handle new user
        let storyboard = UIStoryboard(name: "newSplit", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "evenSplitView")
        // set the stack so that it only contains main and animate it
        let viewControllers = [vc]
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }

}
