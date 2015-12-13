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
    
    func testDeclineUpdateOfferedBecomesDecliningAndRevertsDescription() {
        let flag = createFlag()
        try! flag.description("Original description")
        flag.invite("Madeleine")
        flag.receivingUpdate(createFlag("External description"))
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
    
//    func testUpdateOldFlag() {
//        let flag1 = createFlag()
//        let flag2 = Flag.create("id", type: "type", description: "new description", location: CLLocationCoordinate2D(latitude: 3.0, longitude: 4.0), originator: "new originator", orientation: UIDeviceOrientation.FaceUp, when: NSDate.distantFuture())
//        flag1.invite("Leon")
//        flag2.update(flag1)
//        XCTAssertEqual(flag2.invitees().count, 1)
//        XCTAssertEqual(flag2.invitees()[0].name(), "Leon")
//        XCTAssertEqual(flag2.location().latitude, 3.0)
//        XCTAssertEqual(flag2.originator(), "originator")
//        XCTAssertEqual(flag2.state(), FlagState.ReceivingUpdate)
//        XCTAssertEqual(flag2.description(), "new description")
//        XCTAssertEqual(flag2.when(), NSDate.distantFuture())
//    }
//    
//    func testUpdateOldFlagThenDecline() {
//        let flag1 = createFlag()
//        let flag2 = Flag.create("id", type: "type", description: "new description", location: CLLocationCoordinate2D(latitude: 3.0, longitude: 4.0), originator: "new originator", orientation: UIDeviceOrientation.FaceUp, when: NSDate.distantFuture())
//        flag1.invite("Leon")
//        flag2.update(flag1)
//        flag2.declining("Madeleine")
//        XCTAssertEqual(flag2.invitees().count, 1)
//        XCTAssertEqual(flag2.invitees()[0].name(), "Leon")
//        XCTAssertEqual(flag2.location().latitude, 1.0)
//        XCTAssertEqual(flag2.originator(), "originator")
//        XCTAssertEqual(flag2.state(), FlagState.Neutral)
//        XCTAssertEqual(flag2.description(), "description")
//        XCTAssertEqual(flag2.when(), flag1.when())
//    }
    
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
