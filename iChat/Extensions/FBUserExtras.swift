//
//  FBUserExtras.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/12/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

extension User {
    func asContact() -> Contact {
        return Contact(user: self)
    }
}

extension DataSnapshot {
    func asContact() -> Contact {
        return Contact(snapshot: self)
    }
}
