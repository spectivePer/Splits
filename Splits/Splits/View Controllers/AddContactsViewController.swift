//
//  AddContactsViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 2/27/21.
//

import Foundation
import UIKit

class AddContactsViewController: UIViewController {
    
    @IBOutlet weak var splitName: UITextField!
    @IBOutlet weak var splitWithLabel: UILabel!
    
    @IBOutlet weak var friendsTable: UITableView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var friends: [String: String] = [:]
    var friendsArray: [String] = []
    var friendsIDArray: [String] = []
    var chosenFriends: [String: String] = [:]
    var friendsDict: [String:String] = [:]
    var splittersNames: String = "Participants: "
    
    var searching = false
    var searchedFriends = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        importContacts()

        self.friendsTable.dataSource = self
        self.friendsTable.delegate = self
        self.searchBar.delegate = self

        friendsTable.isHidden = true
        buttonView.isHidden = false

    }

    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @IBAction func previousView(_ sender: UIButton) {
        displayView(storyboard: "Main", vcName: "homeView")
    }
    //TODO: selects contacts to add to split from table
    //TODO: recent/most splitting contacts at the top
    //TODO: user enter split name
    
    @IBAction func splitEvenlyButton(_ sender: Any) {
        displayEvenSplitView(vcName: "evenSplitView")
    }
    
    @IBAction func splitUnevenlyButton(_ sender: Any) {
        displayEvenSplitView(vcName: "unevenSplitView")
    }
    
    func displayView(storyboard: String, vcName: String) {
            // handle new user
            let sb = UIStoryboard(name: storyboard, bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
    }

    func displayEvenSplitView(vcName: String) {
        guard let splitName = splitName.text else {return}

        // create new group with the chosen friends to split with
        GroupService.createGroup(groupName: splitName, users: chosenFriends) { (group, uid, users) in
            UserService.addGroupIDToUsers(uid: uid, groupName: splitName, users: users)
            // handle new user
            let storyboard = UIStoryboard(name: "newSplit", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: vcName)
            // set the stack so that it only contains main and animate it
            let viewControllers = [vc]
            self.navigationController?.setViewControllers(viewControllers, animated: true)
        }
        
    }

    func getFriends() {
        UserService.updateCurrentUser(user: User.current) { [self] (updatedUser) in
            guard let upUser = updatedUser else {
                print("no user available")
                return
            }
            User.setCurrent(upUser, writeToUserDefaults: true)
            
            friendsArray.append(contentsOf: Array(upUser.friends.values))
            friendsIDArray.append(contentsOf: Array(upUser.friends.keys))
            
            self.friendsTable.reloadData()
        }
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
        print(chosenFriends)
        splittersNames = "Participants: "
        chosenFriends.forEach{ name in
            splittersNames += name.value + ", "
        }
        splitWithLabel.text? = splittersNames

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
        
        splittersNames = "Participants: "
        chosenFriends.forEach{ name in
            splittersNames += name.value + ", "
        }
        splitWithLabel.text? = splittersNames
    }
}


extension AddContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(friendsArray)
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
        friendsTable.isHidden = false
        buttonView.isHidden = true
        searchedFriends = friendsArray.filter{ $0.lowercased().prefix(searchText.count) == searchText.lowercased() }
        searching = true
        friendsTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        friendsTable.isHidden = true
        buttonView.isHidden = false
        searching = false
        searchBar.text = ""
        friendsTable.reloadData()
        self.view.endEditing(true)
    }
    
}
