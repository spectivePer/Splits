//
//  AddContactsViewController.swift
//  Splits
//
//  Created by Jocelyn Park on 2/27/21.
//

import Foundation
import UIKit

class AddContactsViewController: UIViewController {
    
    @IBOutlet weak var friendsTable: UITableView!
    var friends: [String: String] = [:]
    var friendsArray: [String] = []
    var friendsIDArray: [String] = []
    var chosenFriends: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getFriends()
        importContacts()

        self.friendsTable.dataSource = self
        self.friendsTable.delegate = self

    }
    
    @IBAction func previousView(_ sender: UIBarButtonItem) {
        displayView(storyboard: "main", vcName: "homeView")
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
        
        // Check if chosen friends are Users/Non-Users based on phone number
        // let (users, nonUsers) = UserService.checkUsersAreVerified(users: chosenFriends)
        
        // create new group with the chosen friends to split with
        GroupService.createGroup(groupName: "SomeGroupName", users: chosenFriends) { (group, uid) in
            
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
            
//            // For when we implement adding friends as Non-Users
//            for (id, name) in upUser.friends {
//                friends[id] = name
//            }
        }
    }
    
    func importContacts() {
        let req = User.requestUserToAccessContacts()
        print(req)
        if (!req) { return } // return if req is false
        
        let auth = User.checkContactsPermissions()
        print(auth)
        if (!auth) { return } // return if auth is false
        
        // grab contacts
        let contacts = User.grabContacts(user: User.current)
        print(contacts)
        
        friendsArray = Array(contacts.values)
        friendsIDArray = Array(contacts.keys)
        
//        // For when we implement adding friends as Non-Users
//         friends = contacts
    }
}

extension AddContactsViewController: UITableViewDelegate {
    
    // Add the user to the ChosenFriends dicionary
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get the name and ID from respective arrays
        let selectedName = friendsArray[indexPath.row]
        let selectedID = friendsIDArray[indexPath.row]
        
        // if the index does not exist, store the index:ID
        if chosenFriends[selectedID] == nil {
            chosenFriends[selectedID] = selectedName
        }
        print(chosenFriends)
    }
    
    // Remove the user from the chosen friends dictionary
    func tableView(_ tableView:UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        // get the ID from respective arrays
        let selectedID = friendsIDArray[indexPath.row]
        
        chosenFriends.removeValue(forKey: selectedID)
        print(chosenFriends)
    }
}


extension AddContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(friendsArray)
        return friendsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = friendsArray[indexPath.row]
        return cell
    }
}
