//
//  InviteeTest.swift
//  illbeback
//
//  Created by Spencer Ward on 29/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import XCTest

class InviteeTest: XCTestCase {
    fileprivate var invitee: Invitee?
    
    override func setUp() {
        invitee = Invitee(name: "Madeleine")
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
