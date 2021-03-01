//
//  SettingsViewController.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/28/21.
//

import UIKit
import FirebaseAuth

@IBDesignable
class CircularImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var profileView: CircularImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.image = UIImage(named: "person")
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "homeView")
        let viewControllers = [vc]
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
    

    @IBAction func signOutButton(_ sender: Any) {
        print(Auth.auth().currentUser?.uid ?? "no user")
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


}
