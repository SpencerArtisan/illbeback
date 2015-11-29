//
//  FlagToken.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class FlagToken {
    private var _token: String
    
    init(token: String) {
        _token = token
    }
    
    func description() -> String {
        return _token
    }
    
    func description(newDescription: String) {
        _token = newDescription
    }
}