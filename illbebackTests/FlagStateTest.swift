//
//  FlagStateTest.swift
//  illbeback
//
//  Created by Spencer Ward on 01/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import XCTest

class FlagStateTest: XCTestCase {
    func testExample() {
        XCTAssertEqual(FlagState.AcceptingNew, FlagState.fromCode(FlagState.AcceptingNew.code()))
    }
}
