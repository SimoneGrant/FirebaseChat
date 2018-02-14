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
            observeMessages()
        }
    }
    var messages = [Message]()
    
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
        //collection view
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        chatCollectionView?.backgroundColor = UIColor.white
        chatCollectionView?.alwaysBounceVertical = true
        chatCollectionView?.register(MessageLogCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 80)
        chatCollectionView.collectionViewLayout = layout
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
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userMsgRef = Database.database().reference().child("user-messages").child(uid)
        userMsgRef.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            let msgRef = Database.database().reference().child("messages").child(messageID)
            msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                guard let dict = snapshot.value as? [String:AnyObject] else { return }
                let message = Message()
                message.fromID = dict["fromID"] as? String
                message.messageBody = dict["messageBody"] as? String
                message.timestamp = dict["timestamp"] as? NSNumber
                message.toID = dict["toID"] as? String
                
                if message.senderID() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.chatCollectionView.reloadData()
                    }
                }
            })
            
        })
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MessageLogCell
        let msg = messages[indexPath.item]
        cell.textView.text = msg.messageBody
        return cell
    }
    
}

// MARK: - Text field delegate

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
