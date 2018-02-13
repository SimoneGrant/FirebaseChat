//
//  CreateMessageCell.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/11/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit

class FetchUsersCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCellUI() {
        profileImageView.layer.cornerRadius = 30
        profileImageView.layer.masksToBounds = true
    }

}
