//
//  FlagState.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

enum FlagState : String {
    case Neutral = "O"
    case ReceivingUpdate = "u"
    case ReceivedUpdate = "U"
    case AcceptingUpdate = "AU"
    case DecliningUpdate = "DU"
    case ReceivingNew = "n"
    case ReceivedNew = "N"
    case AcceptingNew = "AN"
    case DecliningNew = "DN"
    case Dead = "X"
    
    func code() -> String {
        return rawValue
    }
    
    static func fromCode(code: String) -> FlagState {
        switch code {
        case "F":
            return .Neutral
        case "S":
            return .Neutral
        case "A":
            return .Neutral
        case "D":
            return .Neutral
        case "R":
            return .ReceivedUpdate
        default:
            return FlagState(rawValue: code)!
        }
    }
}