//
//  Channel.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/11/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation
import Firebase

//internal class Channel {
//    internal let id: String
//    internal let name: String
//
//    init(id: String, name: String) {
//        self.id = id
//        self.name = name
//    }
//}

/*
{
    id: {
        {  name :  ""  },
        {  members: [] }
    }
}
*/

internal struct Channel {
    var id: String
    var name: String = "anonymous"
    var members: [String] = []
    init(id: String) {
        self.id = id
        members = []
    }
    init(id: String,
         name: String) {
        self.id = id
        self.name = name
    }
    init(id: String,
         name: String,
         members: [String]) {
        self.id = id
        self.name = name
        self.members = members
    }

    
    func toJSON() -> Any {
        return [
            Fields.members : self.members,
            Fields.name  : self.name
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
    }
}


