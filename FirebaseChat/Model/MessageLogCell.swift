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
        tv.text = "Sample Text"
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        NSLayoutConstraint.activate ([
            textView.rightAnchor.constraint(equalTo: self.rightAnchor),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.widthAnchor.constraint(equalToConstant: 200),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor)
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
