//
//  Message.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/13/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromID: String?
    var messageBody: String?
    var timestamp: NSNumber?
    var toID: String?
    
    //get the id of the person sending a message
    func senderID() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
}
