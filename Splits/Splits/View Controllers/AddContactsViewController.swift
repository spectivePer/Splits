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
    var chosenFriends: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Populate the table with contacts
        self.getFriends()
        self.friendsTable.dataSource = self
        self.friendsTable.delegate = self

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
    
    func displayEvenSplitView(vcName: String) {
        
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
            friendsArray = Array(upUser.friends.keys)
            friends = upUser.friends
            self.friendsTable.reloadData()

        }
    }
}

extension AddContactsViewController: UITableViewDelegate {
    
    // Add the user to the ChosenFriends dicionary
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get the name from friendsArray
        let selectedName = friendsArray[indexPath.row]
        
        // get the ID from friends dict
        if let selectedID = friends[selectedName] {
            
            // if the index does not exist, store the index:ID
            if chosenFriends[selectedName] == nil {
                chosenFriends[selectedName] = selectedID
            }
        }
    }
    
    // Remove the user from the chosen friends dictionary
    func tableView(_ tableView:UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedName = friendsArray[indexPath.row]
        chosenFriends.removeValue(forKey: selectedName)

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
