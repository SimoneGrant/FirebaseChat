//
//  MessageLogViewController.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/12/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit
import Firebase

class MessageLogViewController: UIViewController, UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
        }
    }
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    let cellID = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    
    func setup() {
        messageTextField.delegate = self
        addSeparatorToView()
        //collection view
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        chatCollectionView?.backgroundColor = UIColor.white
        chatCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.height, height: 80)
        chatCollectionView.collectionViewLayout = layout
    }
    
    //add a little flourish
    func addSeparatorToView() {
        let separator = UIView()
        containerView.addSubview(separator)
        separator.backgroundColor = UIColor.lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        //constrants
        NSLayoutConstraint.activate ([
            separator.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            separator.topAnchor.constraint(equalTo: containerView.topAnchor),
            separator.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.7)
            ])
    }
    
    // MARK: - Action
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        let messageRef = Database.database().reference().child("messages")
        let childRef = messageRef.childByAutoId()
        let toID = user!.id!
        let fromID = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        let values: [String:Any] = ["messageBody": messageTextField.text!, "toID": toID, "fromID": fromID, "timestamp": timestamp] 
        childRef.updateChildValues(values) {
            (error, reference) in
            if error != nil {
                print("Could not update message database", error!)
                return
            }
            
            let userMsgRef = Database.database().reference().child("user-messages").child(fromID)
            let messageID = childRef.key
            userMsgRef.updateChildValues([messageID: 1])
            
            let receiverOfUserMsgRef = Database.database().reference().child("user-messages").child(toID)
            receiverOfUserMsgRef.updateChildValues([messageID: 1])
            
            self.messageTextField.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextField.text = ""
        }
    }
    
    func retrieveMessageFromDatabase() {
        let messageRef = Database.database().reference().child("Messages")
        messageRef.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! [String: String]
//            let text = snapshotValue["MessageBody"]!
//            let sender = snapshotValue["Sender"]!
            
            
        }
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        cell.backgroundColor = UIColor.blue
        return cell
    }
    
    // MARK: - Collection view delegate methods
    
//    func collectionView(_ collectionView: UICollectionView, layoutCollectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.height, height: 80)
//    }
    
}

extension MessageLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonPressed(sendButton)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
}
