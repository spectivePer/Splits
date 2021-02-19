//
//  ViewController.swift
//  Splits
//
//  Created by Paul Tsvirinko on 2/18/21.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseDatabase

typealias FIRUser = FirebaseAuth.User

class ViewController: UIViewController {
    
    @IBOutlet var gradientView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {

        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }

        authUI.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            //FUIFacebookAuth(),
            FUIEmailAuth()
        ]
        authUI.providers = providers

        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
        
    }


}

    // MARK: - Extensions

extension ViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
                assertionFailure("Error signing in: \(error.localizedDescription)")
                    return
                }
        
        guard let user = authDataResult?.user
            else { return }

        UserService.show(forUID: user.uid) { (user) in
                if let user = user {
                    // Allows to verify user later
                    User.setCurrent(user, writeToUserDefaults: true)

                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "homeView")
                    // set the stack so that it only contains main and animate it
                    let viewControllers = [vc]
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                    
                    self.view.window?.rootViewController = vc
                    self.view.window?.makeKeyAndVisible()
                    
                } else {
                    // handle new user
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "authView")
                    // set the stack so that it only contains main and animate it
                    let viewControllers = [vc]
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                }
            }
    }
    
}


