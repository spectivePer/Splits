//
//  AuthViewController.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFunctions

class UserInfoViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField! // Will change to phoneNumber Kit later on
    var customer_id = ""
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        //let phoneNumber = "+14157777777" // Default until we add phone number capability
        guard let firUser = Auth.auth().currentUser,
              let name = firUser.displayName,
              let phoneNumber = phoneNumberField.text, // Phone Number
              let username = usernameTextField.text, // Username
              !username.isEmpty else { return }
           
        Functions.functions().httpsCallable("createStripeCustomer").call([ "username" : name]) { (response, error) in
                    if let error = error {
                        print(error)
                    }
                    if let response = (response?.data as? [String: Any]) {
                        self.customer_id = response["customer_id"] as! String
                        print(self.customer_id)
                    }
            UserService.create(firUser, name: name, username: username, phoneNumber: phoneNumber, stripeId: self.customer_id) { (user) in
                guard let user = user else {
                    // handle error
                    
                    return
                }
                
                // Allows to verify user later
                User.setCurrent(user, writeToUserDefaults: true)

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "homeView")
                let viewControllers = [vc]
                self.navigationController?.setViewControllers(viewControllers, animated: true)
                
            }
        }
        print("xcode +" + self.customer_id)
        // Set Root View Controller

    }
}
