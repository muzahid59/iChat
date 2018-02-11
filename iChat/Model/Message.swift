//
//  Message.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/11/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation
import Firebase


struct Message {
    
    var id: String
  //  var channelId: String?
    var from: String?
    var to: String?
    var text: String?
    
    init(id: String) {
        self.id = id
    }
    
    init(id: String,
         from: String,
         to: String,
         text: String) {
        
        self.id = id
        self.from = from
        self.to = to
        self.text = text
        //self.channelId = channelId
    }
    
    init(snapshot: DataSnapshot) {
        self.id = snapshot.key
        guard let value = snapshot.value as? [String: Any] else {
            print("message data snapshot valu not found")
            return
        }
       // self.channelId = value["channelId"] as? String
        self.from = value["from"] as? String
        self.to = value["to"] as? String
        self.text = value["text"] as? String
    }
    
    func toJSON() -> Any {
        return [
            "id"        : self.id,
            "to"        : self.text,
            "from"      : self.from,
            "text"      : self.text
            //"channelId" : self.channelId
        ]
    }
    
    static func saveIntoFireDB(message: Message) {
        if let ref = DBRef.message.ref {
            let newRef = ref.childByAutoId()
            newRef.setValue(message.toJSON())
        }
        
    }
    
}
