//
//  InviteeTest.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import XCTest

class InviteeTest: XCTestCase {
    private var invitee: Invitee2?
    
    override func setUp() {
        invitee = Invitee2(name: "Madeleine")
        super.setUp()
    }
    
    func testInitiallyInviting() {
        XCTAssertEqual(invitee!.state(), InviteeState.Inviting)
    }
    
    func testSuccessfulInvitingBecomesInvited() {
        invitee!.invitingSuccess()
        XCTAssertEqual(invitee!.state(), InviteeState.Invited)
    }
    
    func testFailedInvitingRemainsInviting() {
        invitee!.invitingFailure()
        XCTAssertEqual(invitee!.state(), InviteeState.Inviting)
    }
    
    func testAcceptFromSuccessfullyInvited() {
        invitee!.invitingSuccess()
        invitee!.accepted()
        XCTAssertEqual(invitee!.state(), InviteeState.Accepted)
    }

    func testDeclineFromSuccessfullyInvited() {
        invitee!.invitingSuccess()
        invitee!.declined()
        XCTAssertEqual(invitee!.state(), InviteeState.Declined)
    }
}
