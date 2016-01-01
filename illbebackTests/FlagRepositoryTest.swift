//
//  FlagRepositoryTest.swift
//  illbeback
//
//  Created by Spencer Ward on 04/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import XCTest
import CoreLocation

class FlagRepositoryTest : XCTestCase {
    private let originatorRepository = FlagRepository()
    private let inviteeRepository = FlagRepository()
    private let invitee2Repository = FlagRepository()

    func testEvents() {
        originatorRepository.add(event("an event"))
        originatorRepository.add(flag("not an event"))
        let events = originatorRepository.events()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].description(), "an event")
    }
    
    func testImminentEvents() {
        originatorRepository.add(flag(NSDate(), description: "today event"))
        originatorRepository.add(flag(NSDate.distantFuture(), description: "distant event"))
        let events = originatorRepository.imminentEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].description(), "today event")
    }
    
//    func testPurgeRemovesOldEvents() {
//        repository.add(flag(nil, description: "non event"))
//        repository.add(flag(NSDate(), description: "today event"))
//        repository.add(flag(NSDate.distantPast(), description: "past event"))
//        repository.add(flag(NSDate.distantFuture(), description: "future event"))
//        repository.purge()
//        let flags = repository.flags()
//        XCTAssertEqual(flags.count, 3)
//        XCTAssertEqual(flags[0].description(), "non event")
//        XCTAssertEqual(flags[1].description(), "today event")
//        XCTAssertEqual(flags[2].description(), "future event")
//    }
    
    func testFind() {
        originatorRepository.add(flag("a flag"))
        XCTAssertEqual(originatorRepository.find("id")?.description(), "a flag")
    }
    
    func testFindFails() {
        XCTAssertEqual(originatorRepository.find("unknown"), nil)
    }
    
    func testAdd() {
        originatorRepository.add(flag("a flag"))
        let flags = originatorRepository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "a flag")
    }
    
    func testRemove() {
        let flag1 = flag("a flag")
        originatorRepository.add(flag1)
        originatorRepository.remove(flag1)
        let flags = originatorRepository.flags()
        XCTAssertEqual(flags.count, 0)
    }
    
    func testDeadFlagsIgnored() {
        let flag1 = flag("a flag")
        originatorRepository.add(flag1)
        flag1.kill()
        let flags = originatorRepository.flags()
        XCTAssertEqual(flags.count, 0)
    }
    
    func testDeadEventsIgnored() {
        let event1 = event("a flag")
        originatorRepository.add(event1)
        event1.kill()
        let events = originatorRepository.events()
        XCTAssertEqual(events.count, 0)
    }

    func testOfferNew() {
        let originalFlag = offer()
        
        XCTAssertEqual(originalFlag.description(), "a flag")
        XCTAssertEqual(originalFlag.state(), FlagState.Neutral)
        XCTAssertTrue(originalFlag.invitees().count == 1)
        XCTAssertEqual(originalFlag.invitees()[0].name(), "invitee")
        XCTAssertEqual(originalFlag.invitees()[0].state(), InviteeState.Invited)
    }
    
    func testReceiveNew() {
        let receivedFlag = receive(offer())
        
        XCTAssertEqual(receivedFlag.description(), "a flag")
        XCTAssertEqual(receivedFlag.state(), FlagState.ReceivedNew)
        XCTAssertTrue(receivedFlag.invitees().count == 1)
        XCTAssertEqual(receivedFlag.invitees()[0].name(), "invitee")
        XCTAssertEqual(receivedFlag.invitees()[0].state(), InviteeState.Invited)
    }

    func testReceiveNewAccepted() {
        accept(receive(offer()))

        XCTAssertEqual(originatorFlag().description(), "a flag")
        XCTAssertEqual(originatorFlag().state(), FlagState.Neutral)
        XCTAssertTrue(originatorFlag().invitees().count == 1)
        XCTAssertEqual(originatorFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(originatorFlag().invitees()[0].state(), InviteeState.Accepted)
        
        XCTAssertEqual(inviteeFlag().description(), "a flag")
        XCTAssertEqual(inviteeFlag().state(), FlagState.Neutral)
        XCTAssertTrue(inviteeFlag().invitees().count == 1)
        XCTAssertEqual(inviteeFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(inviteeFlag().invitees()[0].state(), InviteeState.Accepted)
    }
    
    func testTwoInviteesReceiveNewAccepted() {
        accept(receive(offer()))
        acceptByInvitee(receiveByInvitee(offerToInvitee(originatorFlag())))
        
        XCTAssertEqual(originatorFlag().description(), "a flag")
        XCTAssertEqual(originatorFlag().state(), FlagState.Neutral)
        XCTAssertTrue(originatorFlag().invitees().count == 2)
        XCTAssertEqual(originatorFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(originatorFlag().invitees()[0].state(), InviteeState.Accepted)
        XCTAssertEqual(originatorFlag().invitees()[1].name(), "invitee2")
        XCTAssertEqual(originatorFlag().invitees()[1].state(), InviteeState.Accepted)
        
        XCTAssertEqual(inviteeFlag().description(), "a flag")
        XCTAssertEqual(inviteeFlag().state(), FlagState.Neutral)
        XCTAssertTrue(inviteeFlag().invitees().count == 1)
        XCTAssertEqual(inviteeFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(inviteeFlag().invitees()[0].state(), InviteeState.Accepted)
        
        XCTAssertEqual(invitee2Flag().description(), "a flag")
        XCTAssertEqual(invitee2Flag().state(), FlagState.Neutral)
        XCTAssertTrue(invitee2Flag().invitees().count == 2)
        XCTAssertEqual(invitee2Flag().invitees()[0].name(), "invitee")
        XCTAssertEqual(invitee2Flag().invitees()[0].state(), InviteeState.Accepted)
        XCTAssertEqual(invitee2Flag().invitees()[1].name(), "invitee2")
        XCTAssertEqual(invitee2Flag().invitees()[1].state(), InviteeState.Accepted)
    }
    
    func testReceiveNewDeclined() {
        decline(receive(offer()))
        
        XCTAssertEqual(originatorFlag().description(), "a flag")
        XCTAssertEqual(originatorFlag().state(), FlagState.Neutral)
        XCTAssertTrue(originatorFlag().invitees().count == 1)
        XCTAssertEqual(originatorFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(originatorFlag().invitees()[0].state(), InviteeState.Declined)
        
        XCTAssertTrue(inviteeRepository.flags().count == 0)
    }
 
    func testOfferUpdate() {
        let originalFlag = accept(receive(offer()))
        try! originalFlag.description("an updated flag")
        offer(originalFlag)
        
        XCTAssertEqual(originatorFlag().description(), "an updated flag")
        XCTAssertEqual(originatorFlag().state(), FlagState.Neutral)
        XCTAssertTrue(originatorFlag().invitees().count == 1)
        XCTAssertEqual(originatorFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(originatorFlag().invitees()[0].state(), InviteeState.Invited)
    }
    
    func testReceiveUpdate() {
        let originalFlag = accept(receive(offer()))
        try! originalFlag.description("an updated flag")
        receive(offer(originalFlag))
        
        XCTAssertEqual(inviteeFlag().description(), "an updated flag")
        XCTAssertEqual(inviteeFlag().state(), FlagState.ReceivedUpdate)
        XCTAssertTrue(inviteeFlag().invitees().count == 1)
        XCTAssertEqual(inviteeFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(inviteeFlag().invitees()[0].state(), InviteeState.Invited)
    }

    func testReceiveUpdateAccepted() {
        let originalFlag = accept(receive(offer()))
        try! originalFlag.description("an updated flag")
        accept(receive(offer(originalFlag)))
        
        XCTAssertEqual(originatorFlag().description(), "an updated flag")
        XCTAssertEqual(originatorFlag().state(), FlagState.Neutral)
        XCTAssertTrue(originatorFlag().invitees().count == 1)
        XCTAssertEqual(originatorFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(originatorFlag().invitees()[0].state(), InviteeState.Accepted)
        
        XCTAssertEqual(inviteeFlag().description(), "an updated flag")
        XCTAssertEqual(inviteeFlag().state(), FlagState.Neutral)
        XCTAssertTrue(inviteeFlag().invitees().count == 1)
        XCTAssertEqual(inviteeFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(inviteeFlag().invitees()[0].state(), InviteeState.Accepted)
    }

    func testReceiveUpdateDeclined() {
        let originalFlag = accept(receive(offer()))
        try! originalFlag.description("an updated flag")
        decline(receive(offer(originalFlag)))
        
        XCTAssertEqual(originatorFlag().description(), "an updated flag")
        XCTAssertEqual(originatorFlag().state(), FlagState.Neutral)
        XCTAssertTrue(originatorFlag().invitees().count == 1)
        XCTAssertEqual(originatorFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(originatorFlag().invitees()[0].state(), InviteeState.Declined)
    
        XCTAssertEqual(inviteeFlag().description(), "a flag")
        XCTAssertEqual(inviteeFlag().state(), FlagState.Neutral)
        XCTAssertTrue(inviteeFlag().invitees().count == 1)
        XCTAssertEqual(inviteeFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(inviteeFlag().invitees()[0].state(), InviteeState.Declined)
    }
    
    func testInviteeOffersUpdate() {
        accept(receive(offer()))
        try! inviteeFlag().description("an updated flag")
        offerFromInvitee(inviteeFlag())
        
        XCTAssertEqual(inviteeFlag().description(), "an updated flag")
        XCTAssertEqual(inviteeFlag().state(), FlagState.Neutral)
        XCTAssertTrue(inviteeFlag().invitees().count == 2)
        XCTAssertEqual(inviteeFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(inviteeFlag().invitees()[0].state(), InviteeState.Accepted)
        XCTAssertEqual(inviteeFlag().invitees()[1].name(), "originator")
        XCTAssertEqual(inviteeFlag().invitees()[1].state(), InviteeState.Invited)
    }
    
    func testInviteeOfferedUpdateAccepted() {
        accept(receive(offer()))
        try! inviteeFlag().description("an updated flag")
        acceptByOriginator(receiveByOriginator(offerFromInvitee(inviteeFlag())))
        
        XCTAssertEqual(originatorFlag().description(), "an updated flag")
        XCTAssertEqual(originatorFlag().state(), FlagState.Neutral)
        XCTAssertTrue(originatorFlag().invitees().count == 2)
        XCTAssertEqual(originatorFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(originatorFlag().invitees()[0].state(), InviteeState.Accepted)
        XCTAssertEqual(originatorFlag().invitees()[1].name(), "originator")
        XCTAssertEqual(originatorFlag().invitees()[1].state(), InviteeState.Accepted)
        
        XCTAssertEqual(inviteeFlag().description(), "an updated flag")
        XCTAssertEqual(inviteeFlag().state(), FlagState.Neutral)
        XCTAssertTrue(inviteeFlag().invitees().count == 2)
        XCTAssertEqual(inviteeFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(inviteeFlag().invitees()[0].state(), InviteeState.Accepted)
        XCTAssertEqual(inviteeFlag().invitees()[1].name(), "originator")
        XCTAssertEqual(inviteeFlag().invitees()[1].state(), InviteeState.Accepted)
    }
    
    
    func testTwoInviteesReceiveNewAcceptedOneUpdatez() {
        accept(receive(offer()))
        acceptByInvitee(receiveByInvitee(offerToInvitee(originatorFlag())))
        try! inviteeFlag().description("an updated flag")
        acceptByOriginator(receiveByOriginator(offerFromInvitee(inviteeFlag())))
        
        XCTAssertEqual(originatorFlag().description(), "an updated flag")
        XCTAssertEqual(originatorFlag().state(), FlagState.Neutral)
        XCTAssertTrue(originatorFlag().invitees().count == 3)
        XCTAssertEqual(originatorFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(originatorFlag().invitees()[0].state(), InviteeState.Accepted)
        XCTAssertEqual(originatorFlag().invitees()[1].name(), "invitee2")
        XCTAssertEqual(originatorFlag().invitees()[1].state(), InviteeState.Accepted)
        XCTAssertEqual(originatorFlag().invitees()[2].name(), "originator")
        XCTAssertEqual(originatorFlag().invitees()[2].state(), InviteeState.Accepted)
        
        XCTAssertEqual(inviteeFlag().description(), "an updated flag")
        XCTAssertEqual(inviteeFlag().state(), FlagState.Neutral)
        XCTAssertTrue(inviteeFlag().invitees().count == 2)
        XCTAssertEqual(inviteeFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(inviteeFlag().invitees()[0].state(), InviteeState.Accepted)
        XCTAssertEqual(inviteeFlag().invitees()[1].name(), "originator")
        XCTAssertEqual(inviteeFlag().invitees()[1].state(), InviteeState.Accepted)
        
        XCTAssertEqual(invitee2Flag().description(), "a flag")
        XCTAssertEqual(invitee2Flag().state(), FlagState.Neutral)
        XCTAssertTrue(invitee2Flag().invitees().count == 2)
        XCTAssertEqual(invitee2Flag().invitees()[0].name(), "invitee")
        XCTAssertEqual(invitee2Flag().invitees()[0].state(), InviteeState.Accepted)
        XCTAssertEqual(invitee2Flag().invitees()[1].name(), "invitee2")
        XCTAssertEqual(invitee2Flag().invitees()[1].state(), InviteeState.Accepted)
    }
    
    
    
    
    func testInviteeOfferedUpdateDeclined() {
        accept(receive(offer()))
        try! inviteeFlag().description("an updated flag")
        declineByOriginator(receiveByOriginator(offerFromInvitee(inviteeFlag())))
        
        XCTAssertEqual(originatorFlag().description(), "a flag")
        XCTAssertEqual(originatorFlag().state(), FlagState.Neutral)
        XCTAssertTrue(originatorFlag().invitees().count == 2)
        XCTAssertEqual(originatorFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(originatorFlag().invitees()[0].state(), InviteeState.Accepted)
        XCTAssertEqual(originatorFlag().invitees()[1].name(), "originator")
        XCTAssertEqual(originatorFlag().invitees()[1].state(), InviteeState.Declined)
        
        XCTAssertEqual(inviteeFlag().description(), "an updated flag")
        XCTAssertEqual(inviteeFlag().state(), FlagState.Neutral)
        XCTAssertTrue(inviteeFlag().invitees().count == 2)
        XCTAssertEqual(inviteeFlag().invitees()[0].name(), "invitee")
        XCTAssertEqual(inviteeFlag().invitees()[0].state(), InviteeState.Accepted)
        XCTAssertEqual(inviteeFlag().invitees()[1].name(), "originator")
        XCTAssertEqual(inviteeFlag().invitees()[1].state(), InviteeState.Declined)
    }
    
    private func offer() -> Flag {
        return offer("invitee")
    }
    
    private func offerToInvitee(offeredFlag: Flag) -> Flag {
        return offer(offeredFlag, to: "invitee2")
    }
    
    private func offer(to: String) -> Flag {
        let offeredFlag = flag("a flag")
        originatorRepository.add(offeredFlag)
        return offer(offeredFlag, to: to)
    }

    private func offer(offeredFlag: Flag) -> Flag {
        return offer(offeredFlag, to: "invitee")
    }
    
    private func offer(offeredFlag: Flag, to: String) -> Flag {
        offeredFlag.invite(to).inviteSuccess()
        return originatorFlag()
    }
    
    private func offerFromInvitee(offeredFlag: Flag) -> Flag {
        offeredFlag.invite("originator").inviteSuccess()
        return inviteeFlag()
    }
    
    private func receive(offeredFlag: Flag) -> Flag {
        return receive(offeredFlag, from: "originator", to: "invitee", toRepository: inviteeRepository)
    }
    
    private func receiveByInvitee(offeredFlag: Flag) -> Flag {
        return receive(offeredFlag, from: "originator", to: "invitee2", toRepository: invitee2Repository)
    }
    
    private func receiveByOriginator(offeredFlag: Flag) -> Flag {
        return receive(offeredFlag, from: "invitee", to: "originator", toRepository: originatorRepository)
    }
    
    private func receive(offeredFlag: Flag, from: String, to: String, toRepository: FlagRepository) -> Flag {
        let receivedFlag = transfer(offeredFlag)
        toRepository.receive(from, to: to, flag: receivedFlag, onNew: { flag in try! flag.receiveNewSuccess(); toRepository.add(flag) }, onUpdate: {flag in try! flag.receiveUpdateSuccess() }, onAck: { _ in XCTFail() })
        return toRepository.flags()[0]
    }
    
    private func accept(receivedFlag: Flag) -> Flag {
        accept(receivedFlag, from: "invitee", to: "originator", toRepository: originatorRepository)
        return originatorFlag()
    }
    
    private func acceptByInvitee(receivedFlag: Flag) -> Flag {
        accept(receivedFlag, from: "invitee2", to: "originator", toRepository: originatorRepository)
        return originatorFlag()
    }
    
    private func acceptByOriginator(receivedFlag: Flag) -> Flag {
        accept(receivedFlag, from: "originator", to: "invitee", toRepository: inviteeRepository)
        return inviteeFlag()
    }
    
    private func decline(receivedFlag: Flag) -> Flag {
        decline(receivedFlag, from: "invitee", to: "originator", toRepository: originatorRepository)
        return originatorFlag()
    }
    
    private func declineByOriginator(receivedFlag: Flag) -> Flag {
        decline(receivedFlag, from: "originator", to: "invitee", toRepository: inviteeRepository)
        return inviteeFlag()
    }
    
    private func decline(receivedFlag: Flag, from: String, to: String, toRepository: FlagRepository)  {
        let invitee = receivedFlag.declining(from)
        let returnedFlag = transfer(receivedFlag)
        var calledBack = false
        toRepository.receive(from, to: to, flag: returnedFlag, onNew: { _ in XCTFail() }, onUpdate: { _ in XCTFail() }, onAck: { _ in calledBack = true })
        XCTAssertTrue(calledBack)
        receivedFlag.declineSuccess(invitee)
    }
    
    private func accept(receivedFlag: Flag, from: String, to: String, toRepository: FlagRepository) {
        let invitee = receivedFlag.accepting(from)
        let returnedFlag = transfer(receivedFlag)
        var calledBack = false
        toRepository.receive(from, to: to, flag: returnedFlag, onNew: { _ in XCTFail() }, onUpdate: { _ in XCTFail() }, onAck: { _ in calledBack = true })
        XCTAssertTrue(calledBack)
        receivedFlag.acceptSuccess(invitee)
    }

    private func originatorFlag() -> Flag {
        XCTAssertTrue(originatorRepository.flags().count == 1)
        return originatorRepository.flags()[0]
    }
    
    private func inviteeFlag() -> Flag {
        XCTAssertTrue(inviteeRepository.flags().count == 1)
        return inviteeRepository.flags()[0]
    }
    
    private func invitee2Flag() -> Flag {
        XCTAssertTrue(invitee2Repository.flags().count == 1)
        return invitee2Repository.flags()[0]
    }
    
    private  func transfer(flag: Flag) -> Flag {
        return Flag.decode(flag.encode())
    }
    
    private func event(description: String) -> Flag {
        return flag(NSDate(), description: description)
    }
    
    private func flag(description: String) -> Flag {
        return flag(nil, description: description)
    }
    
    private func flag(when: NSDate?, description: String) -> Flag {
        return Flag.create("id", type: "type", description: description, location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), originator: "originator", orientation: UIDeviceOrientation.FaceUp, when: when)
    }
}