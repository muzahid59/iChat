//
//  Session.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/11/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation


class App {
    
    var loggedUser: Contact?
    
    class var shared: App {
        struct Static {
            static var instance = App()
        }
        return Static.instance
    }
}
