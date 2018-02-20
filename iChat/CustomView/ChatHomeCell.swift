//
//  ChatHomeCell.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/20/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit

class ChatHomeCell: UITableViewCell {
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
