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
    case UpdateOffered = "U"
    case AcceptingUpdate = "AU"
    case DecliningUpdate = "DU"
    case NewOffered = "N"
    case AcceptingNew = "AN"
    case DecliningNew = "DN"
    case Dead = "X"
    
    func code() -> String {
        return rawValue
    }
    
    static func fromCode(code: String) -> FlagState {
        return FlagState(rawValue: code)!
    }
}