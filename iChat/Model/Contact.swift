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
            self.email = value[fields.email] as? String
            self.displayName = value[fields.displayName] as? String
            self.photoUrl = value[fields.photoUrl] as? String
        }
    }
    
    func toJSON() -> Any {
        return [
            fields.email        : self.email,
            fields.displayName  : self.displayName,
            fields.photoUrl     : self.photoUrl
        ]
    }
    func saveIntoFireDB() {
        guard let ref = DBRef.contact.ref else {
           return
        }
        let newRef = ref.child(self.uid)
        newRef.setValue(toJSON())
    }
}

// MARK:- All Properties

extension Contact {
    struct fields {
        static let uid              = "uid"
        static let email            = "email"
        static let displayName      = "displayName"
        static let photoUrl         = "photoUrl"
    }
}
