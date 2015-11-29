//
//  FlagTest.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import XCTest

class FlagTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testInitiallyNeutral() {
        let flag = createFlag()
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testUpdateNeutralRemainsNeutral() throws {
        let flag = createFlag()
        try flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testExternalUpdateNeutralBecomesUpdateOffered() {
        let flag = createFlag()
        let token = createToken()
        flag.externalUpdate(token)
        XCTAssertEqual(flag.state(), FlagState.UpdateOffered)
    }
    
    func testExternalUpdateChangesDescription() {
        let flag = createFlag()
        let token = createToken("External description")
        flag.externalUpdate(token)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testCannotUpdateUpdateOfferedFlag() {
        let flag = createFlag()
        let token = createToken()
        flag.externalUpdate(token)
        assertError({ try flag.update("New description") })
    }
    
    
    private func assertError(code: () throws -> Void) {
        do {
            try code()
            XCTFail("Exception expected")
        } catch {
            // Good
        }
    }
    
    private func createFlag() -> Flag {
        return Flag()
    }
    
    private func createToken() -> FlagToken {
        return FlagToken(token: "dummy")
    }

    private func createToken(description: String) -> FlagToken {
        return FlagToken(token: description)
    }
}
