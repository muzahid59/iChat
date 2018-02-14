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

struct Message {
    
    var id: String
    var channelId: String?
    var from: String?
    var to: String?
    var text: String?
    var photoURL: String?
    
    init(id: String) {
        self.id = id
    }
    
    init(id: String,
         from: String,
         to: String,
         text: String,
         channelId: String,
         photoURL: String) {
        
        self.id = id
        self.from = from
        self.to = to
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
        self.channelId = value["channelId"] as? String
        self.from = value["from"] as? String
        self.to = value["to"] as? String
        self.text = value["text"] as? String
        self.photoURL = value["photoURL"] as? String
    }
    
    func toJSON() -> Any {
        return [
            "to"        : self.text,
            "from"      : self.from,
            "text"      : self.text,
            "channelId" : self.channelId,
            "photoURL"  : self.photoURL
        ]
    }
    
    static func saveIntoFireDB(message: Message) {
        if let ref = DBRef.message.ref {
            let newRef = ref.childByAutoId()
            newRef.setValue(message.toJSON())
        }
        
    }
    
}
