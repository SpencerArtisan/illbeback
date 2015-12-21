//
//  User.swift
//  illbeback
//
//  Created by Spencer Ward on 22/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

class User {
    private var name: String?
    private var friends: [String]
    
    init(name: String?, friends: [String]) {
        self.name = name
        self.friends = friends
    }
    
    func getName() -> String {
        return name!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func setName(name: String) {
        self.name = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        print("Setting user name to \(self.name)")
    }
    
    func hasName() -> Bool {
        return name != nil && getName() != ""
    }
    
    func getFriends() -> [String] {
        return friends
    }
    
    func addFriend(friend: String) {
        friends.append(friend)
    }
    
    func removeFriend(friend: String) {
        let index = friends.indexOf(friend)
        friends.removeAtIndex(index!)
    }
}