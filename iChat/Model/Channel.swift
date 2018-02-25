//
//  Channel.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/11/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation
import Firebase

/*
{
    id: {
          name :  ""
          members: []
            isGroup : Boolean
    }
}
*/


internal enum ChatType: String {
    case Chat
    case GroupChat
}

internal struct Channel {
    var id: String
    var name: String? = "anonymous"
    var members: [String]? = []
    var type: String? = ChatType.Chat.rawValue
    var senderId: String?
    var senderDisplayName: String?
    var receiverId: String?
    var lastMessage: String?
    
    init(id: String) {
        self.id = id
    }
    
    init(id: String,
         name: String = "anonymous",
         members: [String]? = [],
         senderId: String? = nil,
         senderDisplayName: String? = nil,
         receiverId: String? = nil,
         lastMessage: String? = nil) {
        self.id = id
        self.name = name
        self.members = members
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.receiverId = receiverId
        self.lastMessage = lastMessage
    }
    
    init(snapshot: DataSnapshot) {
        self.id = snapshot.key
        if let value = snapshot.value as? [String: Any] {
            self.name = value[Fields.name] as? String
            self.members = value[Fields.members] as? [String]
            self.type = value[Fields.type] as? String
            self.senderId = value[Fields.senderId] as? String
            self.lastMessage = value[Fields.lastMessage] as? String
            self.senderDisplayName = value[Fields.senderDisplayName] as? String
        }
    }
    
    func toJSON() -> [String : Any?] {
        return [
            Fields.members              : self.members,
            Fields.name                 : self.name,
            Fields.senderId             : self.senderId,
            Fields.type                 : self.type,
            Fields.lastMessage          : self.lastMessage,
            Fields.senderDisplayName    : self.senderDisplayName
        ]
    }
    
    static func getId(from: String, to: String) -> String {
        return String((from + to).sorted())
    }
    
}

extension Channel {
    /// create new channel
    static func createChannel(from: Contact, to: Contact) -> DatabaseReference? {
        if let channelRef: DatabaseReference = DBRef.channel.ref {
            
            let key = Channel.getId(from: from.uid, to: to.uid)
            
            let newRef = channelRef.child(key)
            
            var channel = Channel(id: key)
            channel.members = [from.uid, to.uid]
            
            newRef.setValue(channel.toJSON()) // save into fire db
            
            return newRef
        }
        
        return nil
    }
}

// MARK:- All Properties

extension Channel {
    struct Fields {
        static let id       = "id"
        static let name     = "name"
        static let members  = "members"
        static let type  = "type"
        static let senderId  = "senderId"
        static let senderDisplayName = "senderDisplayName"
        static let lastMessage  = "lastMessage"
    }
}


