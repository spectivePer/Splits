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
        displayViewController(storyboard: "Create", vcName: "addContactsVC")
    }

    func signOutMenu() -> UIMenu {
        let signOut = UIAction(
            title: "Sign Out",
            attributes: .destructive){ (_) in
            print("Sign Out from App")
            do {
                
                try Auth.auth().signOut()
                
                self.displayViewController(storyboard: "Login", vcName: "loginView")
                
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

extension UIViewController {
    func displayViewController(storyboard: String, vcName: String) {
            let sb = UIStoryboard(name: storyboard, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcName)
        
            // set the stack so that it only contains vc and animates it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
}

class SplitsTableCell: UITableViewCell {
    let splits: String = ""
    let sections: [String] = ["Pending Payments", "Pending Charges", "Completed Splits"]
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
    
        switch section {
        case 0: rowCount = splits.count
        case 1: rowCount = splits.count
        case 2: rowCount = splits.count
        }
    
        return rowCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let ip = indexPath
        cell.textLabel?.text = Data1[ip.row] as String
        return cell
    }
}
