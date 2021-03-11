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
    @IBOutlet weak var splitCollection: UICollectionView!
    var splitsArray: [Split]?
    var splitKeys = Array<String>()
    var splits = [String:String]()
    var sections: [String] = ["Pending Payments", "Pending Charges", "Completed Splits"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        welcomeLabel.text?.append(User.current.name)
//        UserService.grabUsersSnapshot()
        DispatchQueue.main.async {
            self.getUserSplits()
        }
        settingButton.menu = signOutMenu()
        settingButton.showsMenuAsPrimaryAction = true
        self.splitCollection.dataSource = self
        self.splitCollection.delegate = self
        
        //splitCollection.register(SplitsCollectionCell.self, forCellWithReuseIdentifier: "Cell")
        splitKeys = Array(User.current.splits.keys)
        splits = User.current.splits
        splitCollection.reloadData()
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

    func getUserSplits() {
        for (splitID, splitName) in User.current.splits {
            SplitService.updateUserSplit(splitIds: splitID) { [self] (split) in
                if let newSplit = split {
                    self.splitsArray?.append(newSplit)
                }
            }
        }
        print("Splits: ", self.splitsArray as Any)
        for split in User.current.splits {
            print("Splits: ", split)
        }
        splitCollection.reloadData()
    }
    
    func getUserSplitIDs () {
        DispatchQueue.global(qos: .userInitiated).async {
            SplitService.updateUserSplitIDs(user: User.current)
        }
        splitCollection.reloadData()
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

class SplitsCollectionCell: UICollectionViewCell {
    @IBOutlet weak var splitName: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        splitName.text = "Temp"
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        splitKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "splitCell", for: indexPath as IndexPath) as? SplitsCollectionCell
        let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "splitCell", for: indexPath as IndexPath)
        cell?.splitName.text = splits[splitKeys[indexPath.row]]
        
        return cell ?? cell1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(
            width: collectionView.bounds.width,
            height: 75
        )
    }
    
}
