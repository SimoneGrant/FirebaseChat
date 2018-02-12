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
    
    private func setup() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTriggered))
    }
    
    @objc func cancelTriggered() {
        dismiss(animated: true, completion: nil)
    }
    
    private func fetchUsersFromDatabase() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
//            print(snapshot)
            if let dict = snapshot.value as? [String: AnyObject] {
                let user = User()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! CreateMessageCell
        let user = users[indexPath.row]
        cell.updateCellUI()
        cell.userNameLabel?.text = user.name
        cell.contactLabel?.text = user.email
        cell.profileImageView?.image = UIImage(named: "anon")
        cell.profileImageView?.contentMode = .scaleAspectFit
        //download profile pic
        if let profilePicURL = user.profileImageUrl {
//            let url = URL(string: profilePicURL)
//            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
//                if error != nil {
//                    print(error!)
//                    return
//                }
//                DispatchQueue.main.async {
//                    cell.profileImageView?.image = UIImage(data: data!)
//                }
//            }).resume()
            cell.profileImageView.loadImageWithCache(using: profilePicURL)
        }
        return cell
    }

}
