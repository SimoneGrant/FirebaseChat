//
//  MessageLogViewController.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/12/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit

class MessageLogViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chat Log"
        addSeparatorToView()
    }
    
    //add a little flourish
    func addSeparatorToView() {
        let separator = UIView()
        containerView.addSubview(separator)
        separator.backgroundColor = UIColor.gray
        separator.translatesAutoresizingMaskIntoConstraints = false
        //constrants
        NSLayoutConstraint.activate ([
            separator.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            separator.topAnchor.constraint(equalTo: containerView.topAnchor),
            separator.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
    }
    
    
    
}
