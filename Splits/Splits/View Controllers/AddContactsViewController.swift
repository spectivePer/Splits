//
//  AddContactsViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 2/27/21.
//

import Foundation
import UIKit

class AddContactsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var splitName: UITextField!
    
    @IBOutlet weak var friendsTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectedCollection: UICollectionView!
    @IBOutlet var onTap: UITapGestureRecognizer!
    
    var friends: [String: String] = [:]
    var friendsArray: [String] = []
    var friendsIDArray: [String] = []
    var chosenFriends: [String: String] = [:]
    var friendsDict: [String:String] = [:]
    var splittersNames: [String] = []
    
    
    var searching = false
    var searchedFriends = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        importContacts()
        
        self.friendsTable.dataSource = self
        self.friendsTable.delegate = self
        self.searchBar.delegate = self
        self.splitName.delegate = self
        self.selectedCollection.dataSource = self
        
        selectedCollection.register(CollectionCell.self, forCellWithReuseIdentifier: "cell")
        selectedCollection.reloadData()
        onTap.isEnabled = false
        splitName.text = ""
        
        searchBar.enablesReturnKeyAutomatically = false
        
    }

    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer){
            self.view.endEditing(true)
            onTap.isEnabled = false
    }
    
    @IBAction func enteringName(_ sender: Any) {
        onTap.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(onTap)
        return true
    }
    
    @IBAction func previousView(_ sender: UIButton) {
        displayView(storyboard: "Main", vcName: "homeView")
    }
    
    @IBAction func startSplit(_ sender: Any) {
        guard let splitName = splitName.text else {return}

//         create new split with the chosen friends to split with
        SplitService.createSplit(recipient: User.current, splitName: splitName, users: chosenFriends) { (split, uid, users) in
            UserService.addGroupIDToUsers(uid: uid, splitName: splitName, users: users)
            
            let sb = UIStoryboard(name: "Create", bundle: nil)
            guard let vc = sb.instantiateViewController(withIdentifier: "createSplitVC") as? CreateViewController
            else {
                assertionFailure("CAN'T FIND LOGIN VIEW")
                return
            }
            // set the stack so that it only contains main and animate it
            let friends = Array(self.chosenFriends.values)
            vc.participants = friends
            vc.splitName = splitName
            vc.splitUid = uid
            vc.participantMap = users
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func displayView(storyboard: String, vcName: String) {
            // handle new user
            let sb = UIStoryboard(name: storyboard, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
    }

    func importContacts() {
        let req = User.requestUserToAccessContacts()
        if (!req) { return } // return if req is false
        
        let auth = User.checkContactsPermissions()
        if (!auth) { return } // return if auth is false
        
        // grab contacts
        let contacts = User.grabContacts(user: User.current)
        
        friendsArray = Array(contacts.values)
        friendsIDArray = Array(contacts.keys)
        
        friendsDict = Dictionary(zip(friendsArray, friendsIDArray), uniquingKeysWith: { (first, _) in first })
    }
}

extension AddContactsViewController: UITableViewDelegate {
    
    // Add the user to the ChosenFriends dicionary
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get the name and ID from respective arrays
        
        var selectedName = friendsArray[indexPath.row]
        var selectedID = friendsIDArray[indexPath.row]
    
        if searching {
            selectedName = searchedFriends[indexPath.row]
            selectedID = friendsDict[selectedName] ?? ""
            print(selectedID)
        }
        
        // if the index does not exist, store the index:ID
        if chosenFriends[selectedID] == nil {
            chosenFriends[selectedID] = selectedName
        }
        splittersNames = []
        chosenFriends.forEach{ name in
            splittersNames.append(name.value)
        }
        selectedCollection.reloadData()

    }
    
    // Remove the user from the chosen friends dictionary
    func tableView(_ tableView:UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        // get the ID from respective arrays
        var selectedName = friendsArray[indexPath.row]
        var selectedID = friendsIDArray[indexPath.row]
    
        if searching {
            selectedName = searchedFriends[indexPath.row]
            selectedID = friendsDict[selectedName] ?? ""
            print(selectedID)
        }
                
        chosenFriends.removeValue(forKey: selectedID)
        print(chosenFriends)
        
        splittersNames = []
        chosenFriends.forEach{ name in
            splittersNames.append(name.value)
        }
        selectedCollection.reloadData()
    }
}


extension AddContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedFriends.count
        } else {
            return friendsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if searching {
            cell.textLabel?.text = searchedFriends[indexPath.row]
        } else {
            cell.textLabel?.text = friendsArray[indexPath.row]
        }
        
        return cell
    }
}

extension AddContactsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedFriends = friendsArray.filter{ $0.lowercased().prefix(searchText.count) == searchText.lowercased() }
        searching = true
        friendsTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        friendsTable.reloadData()
        dismissKeyboard(onTap)
    }
}

class CollectionCell: UICollectionViewCell {
    @IBOutlet weak var contactName: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        contactName.text = "Temp"
    }
}

extension AddContactsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(splittersNames.count)
        return splittersNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bro", for: indexPath) as? CollectionCell
        let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "bro", for: indexPath)
        
        cell?.contactName.text = splittersNames[indexPath.row]
    
        return cell ?? cell1
    }
    
    
}


