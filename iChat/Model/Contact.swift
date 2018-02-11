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
    var ref: DatabaseReference?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.displayName = user.displayName
        self.ref = DBRef.contact.ref
    }
    init(uid: String) {
        self.uid = uid
    }
    
    init(snapshot: DataSnapshot) {
        self.uid = snapshot.key
        if let value = snapshot.value as? [String: Any] {
            self.email = value["email"] as? String
            self.displayName = value["displayName"] as? String
        }
    }
    
    func toJSON() -> Any {
        return [
            "uid" : self.uid,
            "email" : self.email,
            "displayName" : self.displayName
        ]
    }
    func saveIntoFireDB() {
        guard let ref = self.ref else {
           return
        }
        let newRef = ref.child(self.uid)
        newRef.setValue([
            "email"         : self.email,
            "displayName"   : self.displayName
            ])
    }
}
