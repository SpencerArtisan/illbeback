//
//  Invitee.swift
//  illbeback
//
//  Created by Spencer Ward on 07/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

public class Invitee {
    let WAITING = "W"
    let ACCEPTED = "A"
    let DECLINED = "D"
    
    var name: String
    var state: String
    
    init(name: String) {
        self.name = name
        self.state = "W"
    }
    
    init(string: String) {
        let parts = string.componentsSeparatedByString(",")
        self.name = parts[0]
        self.state = parts.count > 1 ? parts[1] : "W"
    }
    
    func accept() {
        state = ACCEPTED
    }
    
    func decline() {
        state = DECLINED
    }
    
    func isAccepted() -> Bool {
        return state == ACCEPTED
    }
    
    func isDeclined() -> Bool {
        return state == DECLINED
    }
    
    func asString() -> String {
        return "\(name),\(state)"
    }
}