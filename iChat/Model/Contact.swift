//
//  Contact.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/10/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct Contact {
    var uid: String
    var email: String?
    var displayName: String?
    var photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.displayName = user.displayName
        self.photoUrl = user.photoURL?.absoluteString
    }
    
    init(uid: String) {
        self.uid = uid
    }
    
    init(snapshot: DataSnapshot) {
        self.uid = snapshot.key
        if let value = snapshot.value as? [String: Any] {
            self.email = value[Fields.email] as? String
            self.displayName = value[Fields.displayName] as? String
            self.photoUrl = value[Fields.photoUrl] as? String
        }
    }
   
}


// MARK:- Contact Operations

extension Contact {
    /// convert into json
    func toJSON() -> Any {
        return [
            Fields.email        : self.email,
            Fields.displayName  : self.displayName,
            Fields.photoUrl     : self.photoUrl
        ]
    }
    
    /// save contact into firebase db
    func saveIntoFireDB() {
        guard let ref = DBRef.contact.ref else {
            return
        }
        let newRef = ref.child(self.uid)
        newRef.setValue(toJSON())
    }
}

// MARK:- All Properties

extension Contact: CustomStringConvertible {
    struct Fields {
        static let uid              = "uid"
        static let email            = "email"
        static let displayName      = "displayName"
        static let photoUrl         = "photoUrl"
    }
    var description: String {
        return " uid: \(uid)\n email: \(email) \n displayName: \(displayName) \n photoUrl: \(photoUrl)"
    }
}
