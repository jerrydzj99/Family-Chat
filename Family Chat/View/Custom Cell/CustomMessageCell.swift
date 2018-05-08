//
//  CustomMessageCell.swift
//  Family Chat
//
//  Created by Jerry Ding on 2018-05-07.
//  Copyright © 2018 Jerry Ding. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var senderNicknameLabel: UILabel!
    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var messageBodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
