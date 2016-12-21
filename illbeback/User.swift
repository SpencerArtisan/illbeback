//
//  User.swift
//  illbeback
//
//  Created by Spencer Ward on 22/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//

import Foundation

class User {
    fileprivate var name: String?
    fileprivate var friends: [String]
    
    init(name: String?, friends: [String]) {
        self.name = name
        self.friends = friends
    }
    
    func getName() -> String {
        return name!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func setName(_ name: String) {
        self.name = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        print("Setting user name to \(self.name)")
    }
    
    func hasName() -> Bool {
        return name != nil && getName() != ""
    }
    
    func getFriends() -> [String] {
        return friends
    }
    
    func addFriend(_ friend: String) {
        friends.append(friend)
    }
    
    func removeFriend(_ friend: String) {
        let index = friends.index(of: friend)
        friends.remove(at: index!)
    }
}
