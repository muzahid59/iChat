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

internal struct Channel {
    var id: String
    var name: String? = "anonymous"
    var members: [String]? = []
    var isGroup: Bool? = false
    var senderId: String?
    var receiverId: String?
    var lastMessage: String?
    
    init(id: String) {
        self.id = id
        members = []
    }
    init(id: String,
         name: String = "anonymous",
         members: [String]? = [],
         isGroup: Bool? = false,
         senderId: String? = nil,
         receiverId: String? = nil,
         lastMessage: String? = nil) {
        self.id = id
        self.name = name
        self.members = members
        self.isGroup = isGroup
        self.senderId = senderId
        self.receiverId = receiverId
        self.lastMessage = lastMessage
    }
    
    init(id: String,
         name: String,
         members: [String]) {
        self.id = id
        self.name = name
        self.members = members
    }

    init(snapshot: DataSnapshot) {
        self.id = snapshot.key
        if let value = snapshot.value as? [String: Any] {
            self.name = value[Fields.name] as? String
            self.members = value[Fields.members] as? [String]
            self.isGroup = value[Fields.isGroup] as? Bool
            self.senderId = value[Fields.senderId] as? String
            self.receiverId = value[Fields.receiverId] as? String
            self.lastMessage = value[Fields.lastMessage] as? String
        }
    }
    
    func toJSON() -> Any {
        return [
            Fields.members  : self.members,
            Fields.name     : self.name,
            Fields.senderId : self.senderId,
            Fields.isGroup  : self.isGroup,
            Fields.lastMessage : self.lastMessage,
            Fields.receiverId   : self.receiverId
        ]
    }
    
    static func makeChannelId(from: String, to: String) -> String {
        return String((from + to).sorted())
    }
    
}


extension Channel {
    static func createChannel(from: Contact, to: Contact) -> DatabaseReference? {
        if let channelRef: DatabaseReference = DBRef.channel.ref {
            
            let key = Channel.makeChannelId(from: from.uid, to: to.uid)
            
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
        static let isGroup  = "isGroup"
        static let senderId  = "senderId"
        static let lastMessage  = "lastMessage"
        static let receiverId   = "receiverId"
    }
}


