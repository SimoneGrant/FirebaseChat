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

class MessagesTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var pickerButton: UIBarButtonItem!
    let profileImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupUI()
        isUserLoggedIn()
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
        //create container view for custom navigation bar
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
    
    var capturedUser: User?
    func showChatControllerForUser(_ user: User) {
        capturedUser = user
        self.performSegue(withIdentifier: "goToChatLog", sender: self)
    }

    func getMessageLog() {
        self.performSegue(withIdentifier: "goToChatLog", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChatLog" {
            let destinationVC = segue.destination as! MessageLogViewController
            destinationVC.user = capturedUser
        }
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
    
    @IBAction func changeUserImageTriggered(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
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
            //navigationImageView.image = image
            profileImageView.image = image
            
        }
        updateNewProfilePic()
        self.dismiss(animated: true, completion: nil)
    }
}
