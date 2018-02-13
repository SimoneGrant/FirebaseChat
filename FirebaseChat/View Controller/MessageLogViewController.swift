//
//  MessageLogViewController.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/12/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit
import Firebase

class MessageLogViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        print(user?.name)
    }
    
    // MARK: - Setup
    
    func setup() {
        messageTextField.delegate = self
        addSeparatorToView()
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
        let values = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextField.text!, "Name": ""]
        childRef.setValue(values) {
            (error, reference) in
            if error != nil {
                print("Could not update message database", error!)
                return
            }
            print("Message saved!")
            self.messageTextField.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextField.text = ""
        }
    }
    
    func retrieveMessageFromDatabase() {
        let messageRef = Database.database().reference().child("Messages")
        messageRef.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! [String: String]
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            
        }
    }
    
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
