//
//  UsersTableViewController.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/10/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import FBSDKCoreKit
import FBSDKLoginKit

class MessagesTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var addChat: UIBarButtonItem!
    @IBOutlet weak var pickerButton: UIBarButtonItem!
    let profileImageView = UIImageView()
    let reuseID = "CustomCell"
    var messages = [Message]()
    var messageDict = [String:Message]()
    var timer: Timer?
    
    var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "add"), for: .normal)
        button.frame = CGRect(x:0, y:0, width: 30, height: 30)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isUserLoggedIn()
        setupView()
    }
    
    func setupView() {
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseID)
        tableView.rowHeight = 80.0
        addChat.customView = addButton
    }
    
//    func isFBLoggedIn() {
//        let current: FBSDKAccessToken?
//        if current?.currentAccessToken {
//            // User is logged in, do work such as go to next view controller.
//        }
//    }
    
    //fan out method to ensure that messages are delivered to the right user
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
//            print(snapshot)
            let userID = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
//                print(snapshot)
                let msgID = snapshot.key
                self.getMessageWith(msgID)
            })
        })
    }
    
    fileprivate func getMessageWith(_ id: String) {
        let msgRef = Database.database().reference().child("messages").child(id)
        msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.fromID = dict["fromID"] as? String
                message.messageBody = dict["messageBody"] as? String
                message.timestamp = dict["timestamp"] as? NSNumber
                message.toID = dict["toID"] as? String
                if let senderID = message.senderID() {
                    self.messageDict[senderID] = message
                }
                self.reloadTable()
            }
        })
    }
        
        fileprivate func reloadTable() {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        }
  
        @objc func handleReloadTable() {
            self.messages = Array(self.messageDict.values)
            self.messages.sort(by: { (message1, message2) -> Bool in
                return message1.timestamp!.intValue > message2.timestamp!.intValue
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
    }
    
    
    func addSeparator(to view: UITableViewCell) {
        let separator = UIView()
        view.addSubview(separator)
        separator.backgroundColor = UIColor.lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        //constrants
        NSLayoutConstraint.activate ([
            separator.leftAnchor.constraint(equalTo: view.leftAnchor),
            separator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separator.widthAnchor.constraint(equalTo: view.widthAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0)
            ])
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as! CustomTableViewCell
//        addSeparator(to: cell)
        let msg = messages[indexPath.row]
        cell.msg = msg
        
        return cell
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
//        print(message.messageBody, message.toID, message.fromID)
        guard let senderID = message.senderID() else { return }
        let ref = Database.database().reference().child("users").child(senderID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot)
            guard let dict = snapshot.value as? [String: AnyObject] else { return }
            let user = User()
            user.id = senderID
            user.name = dict["name"] as? String
            user.profileImageUrl = dict["profileImageUrl"] as? String
            user.email = dict["email"] as? String
            self.showChatControllerForUser(user)
        })
    }
    
    // MARK: - Setup and Action
    
    func logOutUser() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Could not log user out", error)
        }
    }
    
    private func isUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            logOutUser()
        } else {
            setUpNavBarForUser()
        }
    }
    
    func setUpNavBarForUser() {
        messages.removeAll()
        messageDict.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            //                print(snapshot)
            if let dict = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.name = dict["name"] as? String
                user.profileImageUrl = dict["profileImageUrl"] as? String
                user.email = dict["email"] as? String
                self.positionNavInfo(for: user)
            }
        })
    }
    
    func positionNavInfo(for user: User) {
        //create container view custom navigation bar
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
    
        //image
        let navImageView = UIImageView()
        containerView.addSubview(navImageView)
        if let navImageUrl = user.profileImageUrl {
            navImageView.loadImageWithCache(using: navImageUrl)
        }
        navImageView.translatesAutoresizingMaskIntoConstraints = false
        navImageView.contentMode = .scaleAspectFill
        navImageView.layer.cornerRadius = 20
        navImageView.clipsToBounds = true
        //title
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.font = UIFont(name: "Avenir-Heavy", size: 18)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints (anchors,width,height)
        NSLayoutConstraint.activate ([
            //image
            navImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            navImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            navImageView.widthAnchor.constraint(equalToConstant: 40),
            navImageView.heightAnchor.constraint(equalToConstant: 40),
            //title
            nameLabel.leftAnchor.constraint(equalTo: navImageView.rightAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: navImageView.centerYAnchor),
            nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            nameLabel.heightAnchor.constraint(equalTo: navImageView.heightAnchor),
            //container
            containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
            ])

        self.navigationItem.titleView = titleView
    }
    
    @IBAction func logOutTriggered(_ sender: UIBarButtonItem) {
        logOutUser()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func createNewMessage(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Create") as! FetchUsersTableViewController
        vc.messagesController = self
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true, completion: nil)
    }
    
    // Send Data
    
    var capturedUser: User?
    func showChatControllerForUser(_ user: User) {
        capturedUser = user
        self.performSegue(withIdentifier: "goToChatLog", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChatLog" {
            let destinationVC = segue.destination as! MessageLogViewController
            destinationVC.user = capturedUser
        }
    }
    
    // MARK: - Storage
    
    private func updateNewProfilePic() {
        //create unique image id for users
        let uniqueUserImage = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(uniqueUserImage).jpg")
        let databaseRef = Database.database().reference()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        if let image = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                //                    print(metadata)
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    //save image here
                    databaseRef.child("users").child(userID).child("profileImageUrl").setValue(imageURL, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        print("successful image upload")
                    })
                }
            })
        }
    }
    
    // MARK: - Image picker controller
    
    @IBAction func changeUserImageTriggered(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension MessagesTableViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("pressed cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //        print(info)
        var userSelectedImage: UIImage?
        if let pickerEditedImg = info["UIImagePickerControllerEditedImage"] as? UIImage {
            userSelectedImage = pickerEditedImg
        } else if let pickerOriginalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            userSelectedImage = pickerOriginalImg
        }
        
        if let image = userSelectedImage {
            profileImageView.image = image
        }
        updateNewProfilePic()
        self.dismiss(animated: true, completion: nil)
    }
}
