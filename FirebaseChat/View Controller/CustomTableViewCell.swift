//
//  CustomTableViewCell.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/13/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

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
        userImageView.layer.cornerRadius = 30
        userImageView.layer.masksToBounds = true
    }
    
}
