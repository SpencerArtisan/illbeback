//
//  InviteeState.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

enum InviteeState: String {
    case Inviting = "i"
    case Invited = "I"
    case Accepting = "a"
    case Accepted = "A"
    case Declining = "d"
    case Declined = "D"
    
    func code() -> String {
        return rawValue
    }
    
    static func fromCode(_ code: String) -> InviteeState {
        switch code {
        case "W":
            return InviteeState.Invited
        default:
            return InviteeState(rawValue: code)!
        }
    }

}
