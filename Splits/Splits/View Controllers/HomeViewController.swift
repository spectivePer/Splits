//
//  HomeViewController.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        welcomeLabel.text?.append(User.current.name)
        
    }
    
    
    @IBAction func createSplitButton(_ sender: Any) {
        displayAddContactsView()
    }
    @IBAction func settingsButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "settingsView")
        // set the stack so that it only contains main and animate it
        let viewControllers = [vc]
        self.navigationController?.setViewControllers(viewControllers, animated: true)    }

    
    func displayAddContactsView() {
        // handle new user
        let storyboard = UIStoryboard(name: "newSplit", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addContactsView")
        // set the stack so that it only contains main and animate it
        let viewControllers = [vc]
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }

}
