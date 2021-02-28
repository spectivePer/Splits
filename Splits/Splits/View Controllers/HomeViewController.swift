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
        welcomeLabel.text?.append(User.current.username)
        
    }
    
    
    @IBAction func createSplitButton(_ sender: Any) {
        displayAddContactsView()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func displayAddContactsView() {
        // handle new user
        let storyboard = UIStoryboard(name: "newSplit", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addContactsView")
        // set the stack so that it only contains main and animate it
        let viewControllers = [vc]
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }

}
