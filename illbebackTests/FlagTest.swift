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
        try! flag.description("New description")
        XCTAssertEqual(flag.description(), "New description")
        XCTAssertEqual(flag.state(), FlagState.Neutral)
    }
    
    func testUpdateNeutralBecomesReceivingUpdateAndLeavesDescription() {
        let flag = createFlag()
        flag.receivingUpdate("from", flag: createFlag("External description"))
        XCTAssertEqual(flag.state(), FlagState.ReceivingUpdate)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testUpdateSuccessChangesDescription() {
        let flag = createFlag()
        flag.receivingUpdate("from", flag: createFlag("External description"))
        try! flag.receiveUpdateSuccess()
        XCTAssertEqual(flag.state(), FlagState.ReceivedUpdate)
        XCTAssertEqual(flag.description(), "External description")
    }
    
    func testReceivingUpdateSuccessGoToReceivedUpdate() {
        let flag = createFlag()
        flag.receivingUpdate("from", flag: createFlag())
        try! flag.receiveUpdateSuccess()
        XCTAssertEqual(flag.state(), FlagState.ReceivedUpdate)
    }
    
    func testDeclineUpdateOfferedBecomesDecliningAndRevertsDescription() {
        let flag = createFlag()
        try! flag.description("Original description")
        flag.invite("Madeleine")
        flag.receivingUpdate("from", flag: createFlag("External description"))
        try! flag.receiveUpdateSuccess()
        flag.declining("Madeleine")
        XCTAssertEqual(flag.description(), "Original description")
    }
    
    func testCanUpdateNeutralFlag() {
        let flag = createFlag()
        try! flag.description("New description")
        XCTAssertEqual(flag.description(), "New description")
    }
    
    func testCannotUpdateReceivedNewFlag() {
        let flag = createFlag("External description")
        try! flag.receivingNew("originator")
        try! flag.receiveNewSuccess()
        assertError({ try flag.description("New description") })
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
