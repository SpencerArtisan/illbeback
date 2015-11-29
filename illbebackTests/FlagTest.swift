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
    
    func testUpdateNeutralRemainsNeutral() {
        let flag = createFlag()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testExternalUpdateNeutralBecomesUpdateOfferedAndChangesDescription() {
        let flag = createFlag()
        let token = createToken("External description")
        flag.externalUpdate(token)
        XCTAssertEqual(flag.state(), FlagState.UpdateOffered)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testAcceptUpdateOfferedBecomesAcceptingAndRetainsDescription() {
        let flag = createFlag()
        let token = createToken("External description")
        try! flag.update("Original description")
        flag.externalUpdate(token)
        try! flag.acceptUpdate()
        XCTAssertEqual(flag.state(), FlagState.AcceptingUpdate)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testSuccessfulAcceptUpdateReturnsToNeutral() {
        let flag = createFlag()
        let token = createToken()
        flag.externalUpdate(token)
        try! flag.acceptUpdate()
        flag.acceptUpdateSuccess()
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testFailedAcceptUpdateRemainsInAccepting() {
        let flag = createFlag()
        let token = createToken()
        flag.externalUpdate(token)
        try! flag.acceptUpdate()
        flag.acceptUpdateFailure()
        XCTAssertEqual(flag.state(), FlagState.AcceptingUpdate)
    }
    
    func testDeclineUpdateOfferedBecomesDecliningAndRevertsDescription() {
        let flag = createFlag()
        let token = createToken("External description")
        try! flag.update("Original description")
        flag.externalUpdate(token)
        try! flag.declineUpdate()
        XCTAssertEqual(flag.state(), FlagState.DecliningUpdate)
        XCTAssertEqual(flag.description(), "Original description")
    }
    
    func testCannotUpdateUpdateOfferedFlag() {
        let flag = createFlag()
        let token = createToken()
        flag.externalUpdate(token)
        assertError({ try flag.update("New description") })
    }
    
    func testCannotAcceptANeutralFlag() {
        let flag = createFlag()
        assertError({ try flag.acceptUpdate() })
    }
    
    func testCannotDeclineANeutralFlag() {
        let flag = createFlag()
        assertError({ try flag.declineUpdate() })
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
