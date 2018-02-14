//
//  CustomTableViewCell.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/13/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit
import Firebase

class CustomTableViewCell: UITableViewCell {
    
    var msg: Message? {
        didSet {
            if let toID = msg?.toID {
                let ref = Database.database().reference().child("users").child(toID)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    //get username in database connected to the ID
                    if let dict = snapshot.value as? [String:AnyObject] {
                        self.userNameLabel?.text = dict["name"] as? String
                        if let profileImageUrl = dict["profileImageUrl"] as? String {
                            self.userImageView.loadImageWithCache(using: profileImageUrl)
                        }
                    }
                    print(snapshot)
                })
            }
            
            userDetailLabel?.text = msg?.messageBody
            if let seconds = msg?.timestamp?.doubleValue {
                let date = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel?.text = dateFormatter.string(from: date)
            }
        }
    }

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userDetailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
    
    func updateCellUI() {
        userImageView.layer.cornerRadius = 25
        userImageView.layer.masksToBounds = true
    }
    
}
