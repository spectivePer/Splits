//
//  HomeViewController.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        welcomeLabel.text?.append(User.current.name)
        UserService.grabUsersSnapshot()
        settingButton.menu = signOutMenu()
        settingButton.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func createSplitButton(_ sender: Any) {
        displayAddContactsView()
    }
    
    func displayAddContactsView() {
        // handle new user
        let storyboard = UIStoryboard(name: "newSplit", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addContactsView")
        // set the stack so that it only contains main and animate it
        let viewControllers = [vc]
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }

    func signOutMenu() -> UIMenu {
        let signOut = UIAction(
            title: "Sign Out",
            attributes: .destructive){ (_) in
            print("Sign Out from App")
            do {
                
                try Auth.auth().signOut()
                
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "loginView")
                let viewControllers = [vc]
                self.navigationController?.setViewControllers(viewControllers, animated: true)
                
                User.removeCurrent(User.current)
                print(Auth.auth().currentUser?.uid ?? "no user 2")
                
            } catch let error {
                print(error)
            }
        }
        
        let menuActions = [signOut]
        
        let addMenu = UIMenu(
            title:"",
            children: menuActions)
        return addMenu
    }
}

