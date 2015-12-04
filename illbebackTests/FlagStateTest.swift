//
//  FlagStateTest.swift
//  illbeback
//
//  Created by Spencer Ward on 01/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import XCTest

class FlagStateTest: XCTestCase {
    func testDecode() {
        XCTAssertEqual(FlagState.AcceptingNew, FlagState.fromCode(FlagState.AcceptingNew.code()))
    }
    
    func testDecodeOldNormal() {
        XCTAssertEqual(FlagState.Neutral, FlagState.fromCode("F"))
    }
    
    func testDecodeOldSent() {
        XCTAssertEqual(FlagState.Neutral, FlagState.fromCode("S"))
    }
    
    func testDecodeOldReceived() {
        XCTAssertEqual(FlagState.UpdateOffered, FlagState.fromCode("R"))
    }
    
    func testDecodeOldAccepted() {
        XCTAssertEqual(FlagState.Neutral, FlagState.fromCode("A"))
    }
    
    func testDecodeOldDeclined() {
        XCTAssertEqual(FlagState.Neutral, FlagState.fromCode("D"))
    }
}