//
//  DBRef.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/7/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation
import FirebaseDatabase

public enum DBRef: String {
    case message = "message"
    case channel = "channel"
    case typingIndicator = "typingIndicator"
    case contact = "contact"
    
    var ref: DatabaseReference? {
        return Database.database().reference(withPath: self.rawValue)
    }
}
