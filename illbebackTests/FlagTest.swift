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
    
    func testUpdateNeutralRemainsNeutral() {
        let flag = createFlag()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testUpdateNeutralBecomesReceivingUpdateAndLeavesDescription() {
        let flag = createFlag()
        flag.receivingUpdate(createFlag("External description"))
        XCTAssertEqual(flag.state(), FlagState.ReceivingUpdate)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testUpdateSuccessChangesDescription() {
        let flag = createFlag()
        flag.receivingUpdate(createFlag("External description"))
        try! flag.receiveUpdateSuccess()
        XCTAssertEqual(flag.state(), FlagState.ReceivedUpdate)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testReceivingUpdateSuccessGoToReceivedUpdate() {
        let flag = createFlag()
        flag.receivingUpdate(createFlag())
        try! flag.receiveUpdateSuccess()
        XCTAssertEqual(flag.state(), FlagState.ReceivedUpdate)
    }
    
    func testAcceptUpdateBecomesAcceptingAndRetainsDescription() {
        let flag = createFlag()
        try! flag.update("Original description")
        flag.receivingUpdate(createFlag("External description"))
        try! flag.receiveUpdateSuccess()
        try! flag.accepting()
        XCTAssertEqual(flag.state(), FlagState.Accepting)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testSuccessfulAcceptUpdateReturnsToNeutral() {
        let flag = createFlag()
        flag.receivingUpdate(createFlag())
        try! flag.receiveUpdateSuccess()
        try! flag.accepting()
        try! flag.acceptSuccess()
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testFailedAcceptUpdateRemainsInAccepting() {
        let flag = createFlag()
        flag.receivingUpdate(createFlag())
        try! flag.receiveUpdateSuccess()
        try! flag.accepting()
        try! flag.acceptFailure()
        XCTAssertEqual(flag.state(), FlagState.Accepting)
    }
    
    func testDeclineUpdateOfferedBecomesDecliningAndRevertsDescription() {
        let flag = createFlag()
        try! flag.update("Original description")
        flag.receivingUpdate(createFlag("External description"))
        try! flag.receiveUpdateSuccess()
        try! flag.declining()
        XCTAssertEqual(flag.state(), FlagState.Declining)
        XCTAssertEqual(flag.description(), "Original description")
    }
    
    func testSuccessfulDeclineUpdateReturnsToNeutral() {
        let flag = createFlag()
        flag.receivingUpdate(createFlag())
        try! flag.receiveUpdateSuccess()
        try! flag.declining()
        try! flag.declineSuccess()
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testFailedDeclineUpdateRemainsInDeclining() {
        let flag = createFlag()
        flag.receivingUpdate(createFlag())
        try! flag.receiveUpdateSuccess()
        try! flag.declining()
        try! flag.declineFailure()
        XCTAssertEqual(flag.state(), FlagState.Declining)
    }
    
    func testCannotAcceptANeutralFlag() {
        let flag = createFlag()
        assertError({ try flag.accepting() })
    }
    
    func testCannotDeclineANeutralFlag() {
        let flag = createFlag()
        assertError({ try flag.declining() })
    }
    
    func testAcceptReceivedNewBecomesAcceptingAndRetainsDescription() {
        let flag = createFlag("External description")
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        try! flag.accepting()
        XCTAssertEqual(flag.state(), FlagState.Accepting)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testSuccessfulAcceptNewReturnsToNeutral() {
        let flag = createFlag("External description")
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        try! flag.accepting()
        try! flag.acceptSuccess()
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testFailedAcceptNewRemainsInAccepting() {
        let flag = createFlag("External description")
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        try! flag.accepting()
        try! flag.acceptFailure()
        XCTAssertEqual(flag.state(), FlagState.Accepting)
    }
    
    func testDeclineNewOfferedBecomesDeclining() {
        let flag = createFlag("External description")
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        try! flag.declining()
        XCTAssertEqual(flag.state(), FlagState.Declining)
    }
    
    func testSuccessfulDeclineGoesToDead() {
        let flag = createFlag("External description")
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        try! flag.declining()
        try! flag.declineSuccess()
        XCTAssertEqual(flag.state(), FlagState.Dead)
    }
    
    func testFailedDeclineNewRemainsInDeclining() {
        let flag = createFlag("External description")
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        try! flag.declining()
        try! flag.declineFailure()
        XCTAssertEqual(flag.state(), FlagState.Declining)
    }
    
    func testCannotAcceptNewANeutralFlag() {
        let flag = createFlag()
        assertError({ try flag.accepting() })
    }
    
    func testCannotDeclineNewANeutralFlag() {
        let flag = createFlag()
        assertError({ try flag.declining() })
    }
    
    func testCanUpdateNeutralFlag() {
        let flag = createFlag()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
    }
    
    func testCanUpdateAcceptingNewFlag() {
        let flag = createFlag()
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        try! flag.accepting()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
    }
    
    func testCanUpdateAcceptedUpdateFlag() {
        let flag = createFlag()
        flag.receivingUpdate(createFlag())
        try! flag.receiveUpdateSuccess()
        try! flag.accepting()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
    }
    
    func testCanUpdateDeclinedUpdateFlag() {
        let flag = createFlag()
        flag.receivingUpdate(createFlag())
        try! flag.receiveUpdateSuccess()
        try! flag.declining()
        try! flag.declineSuccess()
        try! flag.update("New description")
        XCTAssertEqual(flag.description(), "New description")
    }
    
    func testCannotUpdateReceivedNewFlag() {
        let flag = createFlag("External description")
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        assertError({ try flag.update("New description") })
    }
    
    func testCannotUpdateDecliningNewFlag() {
        let flag = createFlag("External description")
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        try! flag.declining()
        assertError({ try flag.update("New description") })
    }
    
    func testCannotUpdateDeadFlag() {
        let flag = createFlag("External description")
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        try! flag.declining()
        try! flag.declineSuccess()
        assertError({ try flag.update("New description") })
    }
    
    func testInitiallyNoInvitees() {
        let flag = createFlag()
        XCTAssertEqual(flag.invitees().count, 0)
    }
    
    func testInviteCreatesInvitingInvitee() {
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
}
