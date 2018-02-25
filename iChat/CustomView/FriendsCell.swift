//
//  FriendsCell.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/21/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {

    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
