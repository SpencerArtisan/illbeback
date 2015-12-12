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
        invitee!.inviteSuccess()
        XCTAssertEqual(invitee!.state(), InviteeState.Invited)
    }
    
    func testFailedInvitingRemainsInviting() {
        invitee!.inviteFailure()
        XCTAssertEqual(invitee!.state(), InviteeState.Inviting)
    }
    
    func testAcceptFromSuccessfullyInvited() {
        invitee!.inviteSuccess()
        invitee!.accepting()
        XCTAssertEqual(invitee!.state(), InviteeState.Accepting)
    }

    func testDeclineFromSuccessfullyInvited() {
        invitee!.inviteSuccess()
        invitee!.declining()
        XCTAssertEqual(invitee!.state(), InviteeState.Declining)
    }
}
