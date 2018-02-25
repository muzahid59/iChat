//
//  Message.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/11/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation
import Firebase

/*
 FireDB JSON:
     message:{
          "message id one":{
             "channelId": "channel id between sender and receiver",
             "from": "sender uid",
             "to": "receiver uid",
             "text": "message text"
         },
         "message id two":{
         "channelId": "channel id between sender and receiver",
         "from": "sender uid",
         "to": "receiver uid",
         "text": "message text"
         },....
     }
 */

internal struct Message {
    
    var id: String
    var channelId: String?
    var senderId: String?
    var text: String?
    var photoURL: String?
    
    init(id: String) {
        self.id = id
    }
    
    init(id: String,
         senderId: String,
         text: String,
         channelId: String,
         photoURL: String) {
        
        self.id = id
        self.senderId = senderId
        self.text = text
        self.channelId = channelId
        self.photoURL = photoURL
    }
    
    init(snapshot: DataSnapshot) {
        self.id = snapshot.key
        guard let value = snapshot.value as? [String: Any] else {
            print("message data snapshot valu not found")
            return
        }
        self.channelId = value[Fields.channelId] as? String
        self.senderId = value[Fields.senderId] as? String
        self.text = value[Fields.text] as? String
        self.photoURL = value[Fields.photoUrl] as? String
    }
    
    func toJSON() -> Any {
        return [
            Fields.senderId     : self.senderId,
            Fields.text         : self.text,
            Fields.channelId    : self.channelId,
            Fields.photoUrl     : self.photoURL
        ]
    }
    
    static func saveIntoFireDB(message: Message) {
        if let ref = DBRef.message.ref {
            let newRef = ref.childByAutoId()
            newRef.setValue(message.toJSON())
        }
        
    }
    
}


// MARK:- All Properties

extension Message {
    struct Fields {
        static let id           = "id"
        static let channelId    = "channelId"
        static let senderId     = "senderId"
        static let text         = "text"
        static let photoUrl     = "photoURL"
        
    }
}

