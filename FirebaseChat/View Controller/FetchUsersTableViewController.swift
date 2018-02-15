//
//  CreateMessageTableViewController.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/10/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit
import Firebase

class FetchUsersTableViewController: UITableViewController {
    
    var users = [User]()
    var reuseID = "CustomCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchUsersFromDatabase()
    }
    
    // MARK: - Setup
    
    private func setup() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTriggered))
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseID)
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    @objc func cancelTriggered() {
        dismiss(animated: true, completion: nil)
    }
    
    //get list of all users from users database
    private func fetchUsersFromDatabase() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
//            print(snapshot)
            if let dict = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key //set the user id to firebase snapshot key
                user.email = dict["email"] as? String
                user.name = dict["name"] as? String
                user.profileImageUrl = dict["profileImageUrl"] as? String

                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    // MARK: - Table view data souce
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as! CustomTableViewCell
        let user = users[indexPath.row]
        cell.updateCellUI()
        cell.userNameLabel?.text = user.name
        cell.userDetailLabel?.text = user.email
        cell.userImageView?.contentMode = .scaleAspectFit
        cell.timeLabel.isHidden = true
        if let profilePicURL = user.profileImageUrl {
            cell.userImageView.loadImageWithCache(using: profilePicURL)
        }
        
        return cell
    }
    
    // MARK: - Table view delegate methods
    
    var messagesController: MessagesTableViewController?
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            print(user)
            self.messagesController?.showChatControllerForUser(user)
        }
    }
}
