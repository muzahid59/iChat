//
//  Channel.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/11/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation

internal class Channel {
    internal let id: String
    internal let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

/*
{
    id: {
        {  name :  ""  },
        {  members: [] }
    }
}
*/
struct Channel_ {
    var id: String
    var name: String = "anonymous"
    var members: [String] = []
    init(id: String) {
        self.id = id
        members = []
    }
    
    func toJSON() -> Any {
        return [
            "id" : self.id,
            "members" : self.members,
            "name"  : self.name
        ]
    }
    
}
