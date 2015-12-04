//
//  Invitee2StateTest.swift
//  illbeback
//
//  Created by Spencer Ward on 04/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import XCTest

class InviteeStateTest: XCTestCase {
    
    func testDecodeInviting() {
        XCTAssertEqual(InviteeState.Inviting, InviteeState.fromCode(InviteeState.Inviting.code()))
    }
    
    func testDecodeInvited() {
        XCTAssertEqual(InviteeState.Invited, InviteeState.fromCode(InviteeState.Invited.code()))
    }
    
    func testDecodeAccepted() {
        XCTAssertEqual(InviteeState.Accepted, InviteeState.fromCode(InviteeState.Accepted.code()))
    }
    
    func testDecodeDeclined() {
        XCTAssertEqual(InviteeState.Declined, InviteeState.fromCode(InviteeState.Declined.code()))
    }
    
    func testDecodeOldWaiting() {
        XCTAssertEqual(InviteeState.Invited, InviteeState.fromCode("W"))
    }
    
    func testDecodeOldAccepted() {
        XCTAssertEqual(InviteeState.Accepted, InviteeState.fromCode("A"))
    }
    
    func testDecodeOldDeclined() {
        XCTAssertEqual(InviteeState.Declined, InviteeState.fromCode("D"))
    }

}
