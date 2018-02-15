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
        chatCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        chatCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
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
            self.messageTextField.text = nil
        }
    }
    
    //observe sender/receiver info from user-messages and load text from messages
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
        setupCell(cell, message: msg)
        cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        cell.chatBubbleWidthAnchor?.constant = estimateFrame(for: msg.messageBody!).width + 32
        //        print("This is textView contentsize: ", cell.textView.contentSize.width)
        //        print("This is textView estimate frame size: ", estimateFrame(for: msg.messageBody!).width)
        return cell
    }
    
    private func setupCell(_ cell: MessageLogCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageWithCache(using: profileImageUrl)
        }
        if let time = message.timestamp?.doubleValue {
                let date = Date(timeIntervalSince1970: time)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
            cell.timeStampView.text = dateFormatter.string(from: date)
        }
//        cell.timeStampView.text = ""
        
        
        if message.fromID == Auth.auth().currentUser?.uid {
            //outgoing
            cell.chatBubbleView.backgroundColor = MessageLogCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.chatBubbleRightAnchor?.isActive = true
            cell.chatBubbleLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
            cell.timeStampRightAnchor?.isActive = true
            cell.timeStampLeftAnchor?.isActive = false
        } else {
            //incoming
            cell.chatBubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            cell.chatBubbleRightAnchor?.isActive = false
            cell.chatBubbleLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
            cell.timeStampRightAnchor?.isActive = false
            cell.timeStampLeftAnchor?.isActive = true
        }
    }
    
    // MARK: - Collection view delegate methods
    
    //using constraints this will allow the collectionview to maintain its position on rotation
    func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        chatCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellHeight: CGFloat = 80
        if let message = messages[indexPath.item].messageBody {
            //add 20 pixels to extend height to fit all text
            cellHeight = estimateFrame(for: message).height + 20
        }
        
        return CGSize(width: view.frame.width, height: cellHeight)
    }
    
    private func estimateFrame(for text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
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
