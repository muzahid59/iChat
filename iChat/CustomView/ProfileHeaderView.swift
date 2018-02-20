//
//  ProfileHeader.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/18/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit

protocol ProfileHeaderVM {
    
}


class ProfileHeaderView: UIView {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    var profilePicHandler: ((UIImage?) -> Void)?
    var profileNameHandler: ((String?) -> Void)?
    
    @IBAction func editProfilePicButtonPressed(_ sender: Any) {
        profilePicHandler?(profilePic.image)
    }
    
    
    @IBAction func editProfileNameButtonPressed(_ sender: Any) {
        profileNameHandler?(profileName.text)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

}
