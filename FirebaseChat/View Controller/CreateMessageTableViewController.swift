//
//  CreateMessageTableViewController.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/10/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit
import Firebase

class CreateMessageTableViewController: UITableViewController {
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        fetchUsersFromDatabase()
    }
    
    // MARK: - Setup
    
    func setup() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTriggered))
    }
    
    @objc func cancelTriggered() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUsersFromDatabase() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
//            print(snapshot)
            if let dict = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.email = dict["email"] as? String
                user.name = dict["name"] as? String
                
                print(user.name!, user.email!)
                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    // MARK: - Table view data souce
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
    }

}