//
//  MessageLogCell.swift
//  FirebaseChat
//
//  Created by Simone Grant on 2/14/18.
//  Copyright © 2018 Simone Grant. All rights reserved.
//

import UIKit

class MessageLogCell: UICollectionViewCell {
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.text = "Sample Text"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    static let blueColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1.0)
    
    let chatBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "man")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 13
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeStampView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.lightGray
        tv.text = "h:mm a"
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    var chatBubbleWidthAnchor: NSLayoutConstraint?
    var chatBubbleRightAnchor: NSLayoutConstraint?
    var chatBubbleLeftAnchor: NSLayoutConstraint?
    var timeStampLeftAnchor: NSLayoutConstraint?
    var timeStampRightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(timeStampView)
        addSubview(profileImageView)
        addSubview(chatBubbleView)
        addSubview(textView)
        NSLayoutConstraint.activate ([
            timeStampView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 5),
            timeStampView.widthAnchor.constraint(equalToConstant: 70),
            timeStampView.heightAnchor.constraint(equalTo: self.heightAnchor),
            //imageView
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
            //bubbleView
            chatBubbleView.topAnchor.constraint(equalTo: self.topAnchor),
            chatBubbleView.heightAnchor.constraint(equalTo: self.heightAnchor),
            //textView
            //add some padding to view
            textView.leftAnchor.constraint(equalTo: chatBubbleView.leftAnchor, constant: 8),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.rightAnchor.constraint(equalTo: chatBubbleView.rightAnchor),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor)
            ])
        chatBubbleWidthAnchor = chatBubbleView.widthAnchor.constraint(equalToConstant: 200)
        chatBubbleRightAnchor = chatBubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        chatBubbleLeftAnchor = chatBubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        timeStampRightAnchor = timeStampView.trailingAnchor.constraint(equalTo: chatBubbleView.leadingAnchor, constant: -5)
        timeStampLeftAnchor = timeStampView.leadingAnchor.constraint(equalTo: chatBubbleView.trailingAnchor, constant: 5)
        chatBubbleWidthAnchor?.isActive = true
        chatBubbleRightAnchor?.isActive = true
        timeStampLeftAnchor?.isActive = true
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
