//
//  AuthViewController.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserInfoViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField! // Will change to phoneNumber Kit later on
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        //let phoneNumber = "+14157777777" // Default until we add phone number capability
        guard let firUser = Auth.auth().currentUser,
              let phoneNumber = phoneNumberField.text, // Phone Number
              let username = usernameTextField.text, // Username
              !username.isEmpty else { return }
            
        
        // Set Root View Controller
        UserService.create(firUser, username: username, phoneNumber: phoneNumber) { (user) in
            guard let user = user else {
                // handle error
                return
            }
            
            // Allows to verify user later
            User.setCurrent(user, writeToUserDefaults: true)

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "homeView")
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
            
        }
    }
}
