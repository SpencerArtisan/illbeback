//
//  FlagTest.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import XCTest
import CoreLocation

class FlagTest: XCTestCase {

    func testInitiallyNeutral() {
        let flag = createFlag()
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testReceivedFlagInitiallyNewOffered() {
        let token = createToken("External description")
        let flag = createReceivedFlag(token)
        XCTAssertEqual(flag.state(), FlagState.NewOffered)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testUpdateNeutralRemainsNeutral() {
        let flag = createFlag()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testExternalUpdateNeutralBecomesUpdateOfferedAndChangesDescription() {
        let flag = createFlag()
        flag.markAsUpdate(createFlag("External description"))
        XCTAssertEqual(flag.state(), FlagState.UpdateOffered)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testAcceptUpdateOfferedBecomesAcceptingAndRetainsDescription() {
        let flag = createFlag()
        try! flag.update("Original description")
        flag.markAsUpdate(createFlag("External description"))
        try! flag.acceptUpdate()
        XCTAssertEqual(flag.state(), FlagState.AcceptingUpdate)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testSuccessfulAcceptUpdateReturnsToNeutral() {
        let flag = createFlag()
        flag.markAsUpdate(createFlag())
        try! flag.acceptUpdate()
        flag.acceptUpdateSuccess()
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testFailedAcceptUpdateRemainsInAccepting() {
        let flag = createFlag()
        flag.markAsUpdate(createFlag())
        try! flag.acceptUpdate()
        flag.acceptUpdateFailure()
        XCTAssertEqual(flag.state(), FlagState.AcceptingUpdate)
    }
    
    func testDeclineUpdateOfferedBecomesDecliningAndRevertsDescription() {
        let flag = createFlag()
        try! flag.update("Original description")
        flag.markAsUpdate(createFlag("External description"))
        try! flag.declineUpdate()
        XCTAssertEqual(flag.state(), FlagState.DecliningUpdate)
        XCTAssertEqual(flag.description(), "Original description")
    }
    
    func testSuccessfulDeclineUpdateReturnsToNeutral() {
        let flag = createFlag()
        flag.markAsUpdate(createFlag())
        try! flag.declineUpdate()
        flag.declineUpdateSuccess()
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testFailedDeclineUpdateRemainsInDeclining() {
        let flag = createFlag()
        flag.markAsUpdate(createFlag())
        try! flag.declineUpdate()
        flag.declineUpdateFailure()
        XCTAssertEqual(flag.state(), FlagState.DecliningUpdate)
    }
    
    func testCannotAcceptANeutralFlag() {
        let flag = createFlag()
        assertError({ try flag.acceptUpdate() })
    }
    
    func testCannotDeclineANeutralFlag() {
        let flag = createFlag()
        assertError({ try flag.declineUpdate() })
    }
    
    func testAcceptNewOfferedBecomesAcceptingAndRetainsDescription() {
        let token = createToken("External description")
        let flag = createReceivedFlag(token)
        try! flag.acceptNew()
        XCTAssertEqual(flag.state(), FlagState.AcceptingNew)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testSuccessfulAcceptNewReturnsToNeutral() {
        let token = createToken("External description")
        let flag = createReceivedFlag(token)
        try! flag.acceptNew()
        flag.acceptNewSuccess()
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testFailedAcceptNewRemainsInAccepting() {
        let token = createToken("External description")
        let flag = createReceivedFlag(token)
        try! flag.acceptNew()
        flag.acceptNewFailure()
        XCTAssertEqual(flag.state(), FlagState.AcceptingNew)
    }
    
    func testDeclineNewOfferedBecomesDeclining() {
        let token = createToken("External description")
        let flag = createReceivedFlag(token)
        try! flag.declineNew()
        XCTAssertEqual(flag.state(), FlagState.DecliningNew)
    }
    
    func testSuccessfulDeclineGoesToDead() {
        let token = createToken("External description")
        let flag = createReceivedFlag(token)
        try! flag.acceptNew()
        flag.declineNewSuccess()
        XCTAssertEqual(flag.state(), FlagState.Dead)
    }
    
    func testFailedDeclineNewRemainsInDeclining() {
        let token = createToken("External description")
        let flag = createReceivedFlag(token)
        try! flag.acceptNew()
        flag.declineNewFailure()
        XCTAssertEqual(flag.state(), FlagState.AcceptingNew)
    }
    
    func testCannotAcceptNewANeutralFlag() {
        let flag = createFlag()
        assertError({ try flag.acceptNew() })
    }
    
    func testCannotDeclineNewANeutralFlag() {
        let flag = createFlag()
        assertError({ try flag.declineNew() })
    }
    
    func testCanUpdateNeutralFlag() {
        let flag = createFlag()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
    }
    
    func testCanUpdateAcceptingNewFlag() {
        let flag = createReceivedFlag()
        try! flag.acceptNew()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
    }
    
    func testCanUpdateAcceptingUpdateFlag() {
        let flag = createFlag()
        flag.markAsUpdate(createFlag())
        try! flag.acceptUpdate()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
    }
    
    func testCanUpdateDecliningUpdateFlag() {
        let flag = createFlag()
        flag.markAsUpdate(createFlag())
        try! flag.declineUpdate()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
    }
    
    func testCannotUpdateNewOfferedFlag() {
        let token = createToken("External description")
        let flag = createReceivedFlag(token)
        assertError({ try flag.update("New description") })
    }
    
    func testCannotUpdateDecliningNewFlag() {
        let flag = createReceivedFlag()
        try! flag.declineNew()
        assertError({ try flag.update("New description") })
    }
    
    func testCannotUpdateDeadFlag() {
        let flag = createReceivedFlag()
        try! flag.declineNew()
        flag.declineNewSuccess()
        assertError({ try flag.update("New description") })
    }
    
    func testInitiallyNoInvitees() {
        let flag = createFlag()
        XCTAssertEqual(flag.invitees().count, 0)
    }
    
    func testSharingCreatesInvitingInvitee() {
        let flag = createFlag()
        flag.invite("Friend")
        XCTAssertEqual(flag.invitees().count, 1)
        XCTAssertEqual(flag.invitees()[0].name(), "Friend")
        XCTAssertEqual(flag.invitees()[0].state(), InviteeState.Inviting)
    }
    
    private func assertError(code: () throws -> Void) {
        do {
            try code()
            XCTFail("Exception expected")
        } catch {
            // Good
        }
    }
    
    private func createFlag(description: String) -> Flag {
        return Flag.create("id", type: "type", description: description, location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), originator: "originator", orientation: UIDeviceOrientation.FaceUp, when: NSDate())
    }
    
    private func createFlag() -> Flag {
        return createFlag("description")
    }
    
    private func createReceivedFlag() -> Flag {
        return Flag.offered(createToken())
    }
    
    private func createReceivedFlag(token: FlagToken) -> Flag {
        return Flag.offered(token)
    }
    
    private func createToken() -> FlagToken {
        return createToken("description")
    }

    private func createToken(description: String) -> FlagToken {
        return FlagToken(id: "id", state: FlagState.Neutral, type: "type", description: description, location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), originator: "originator", orientation: UIDeviceOrientation.FaceUp, when: NSDate())
    }
}
