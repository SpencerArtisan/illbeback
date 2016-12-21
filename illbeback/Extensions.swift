//
//  Extensions.swift
//  illbeback
//
//  Created by Spencer Ward on 05/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

extension RangeReplaceableCollection where Iterator.Element : Equatable {
    mutating func removeObject(_ object : Iterator.Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}
