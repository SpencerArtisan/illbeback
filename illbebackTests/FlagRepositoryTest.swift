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
    fileprivate let originatorRepository = FlagRepository()
    fileprivate let inviteeRepository = FlagRepository()
    fileprivate let invitee2Repository = FlagRepository()

    func testEvents() {
        originatorRepository.create(event("id1", description: "an event"))
        originatorRepository.create(flag("id2", description: "not an event"))
        let events = originatorRepository.events()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].description(), "an event")
    }
    
    func testImminentEvents() {
        originatorRepository.create(flag("id1", when: Date(), description: "today event"))
        originatorRepository.create(flag("id2", when: Date.distantFuture, description: "distant event"))
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
        originatorRepository.create(flag("id1", description: "a flag"))
        XCTAssertEqual(originatorRepository.find("id1")?.description(), "a flag")
    }
    
    func testFindFails() {
        XCTAssertEqual(originatorRepository.find("unknown"), nil)
    }
    
    func testAdd() {
        originatorRepository.create(flag("id1", description: "a flag"))
        let flags = originatorRepository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "a flag")
    }
    
    func testAddWithDuplicateId() {
        originatorRepository.create(flag("id1", description: "a flag"))
        originatorRepository.create(flag("id1", description: "a duplicate flag"))
        let flags = originatorRepository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "a duplicate flag")
    }
    
    func testRemove() {
        let flag1 = flag("id1", description: "a flag")
        originatorRepository.create(flag1)
        originatorRepository.remove(flag1)
        let flags = originatorRepository.flags()
        XCTAssertEqual(flags.count, 0)
    }
    
    func testDeadFlagsIgnored() {
        let flag1 = flag("id1", description: "a flag")
        originatorRepository.create(flag1)
        flag1.kill()
        let flags = originatorRepository.flags()
        XCTAssertEqual(flags.count, 0)
    }
    
    func testDeadEventsIgnored() {
        let event1 = event("id1", description: "a flag")
        originatorRepository.create(event1)
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
    
    fileprivate func offer() -> Flag {
        return offer("invitee")
    }
    
    fileprivate func offerToInvitee(_ offeredFlag: Flag) -> Flag {
        return offer(offeredFlag, to: "invitee2")
    }
    
    fileprivate func offer(_ to: String) -> Flag {
        let offeredFlag = flag("id1", description: "a flag")
        originatorRepository.create(offeredFlag)
        return offer(offeredFlag, to: to)
    }

    fileprivate func offer(_ offeredFlag: Flag) -> Flag {
        return offer(offeredFlag, to: "invitee")
    }
    
    fileprivate func offer(_ offeredFlag: Flag, to: String) -> Flag {
        offeredFlag.invite(to).inviteSuccess()
        return originatorFlag()
    }
    
    fileprivate func offerFromInvitee(_ offeredFlag: Flag) -> Flag {
        offeredFlag.invite("originator").inviteSuccess()
        return inviteeFlag()
    }
    
    fileprivate func receive(_ offeredFlag: Flag) -> Flag {
        return receive(offeredFlag, from: "originator", to: "invitee", toRepository: inviteeRepository)
    }
    
    fileprivate func receiveByInvitee(_ offeredFlag: Flag) -> Flag {
        return receive(offeredFlag, from: "originator", to: "invitee2", toRepository: invitee2Repository)
    }
    
    fileprivate func receiveByOriginator(_ offeredFlag: Flag) -> Flag {
        return receive(offeredFlag, from: "invitee", to: "originator", toRepository: originatorRepository)
    }
    
    fileprivate func receive(_ offeredFlag: Flag, from: String, to: String, toRepository: FlagRepository) -> Flag {
        let receivedFlag = transfer(offeredFlag)
        toRepository.receive(from, to: to, flag: receivedFlag, onNew: { flag in try! flag.receiveNewSuccess(); toRepository.create(flag) }, onUpdate: {flag in try! flag.receiveUpdateSuccess() }, onAck: { _ in XCTFail() })
        return toRepository.flags()[0]
    }
    
    fileprivate func accept(_ receivedFlag: Flag) -> Flag {
        accept(receivedFlag, from: "invitee", to: "originator", toRepository: originatorRepository)
        return originatorFlag()
    }
    
    fileprivate func acceptByInvitee(_ receivedFlag: Flag) -> Flag {
        accept(receivedFlag, from: "invitee2", to: "originator", toRepository: originatorRepository)
        return originatorFlag()
    }
    
    fileprivate func acceptByOriginator(_ receivedFlag: Flag) -> Flag {
        accept(receivedFlag, from: "originator", to: "invitee", toRepository: inviteeRepository)
        return inviteeFlag()
    }
    
    fileprivate func decline(_ receivedFlag: Flag) -> Flag {
        decline(receivedFlag, from: "invitee", to: "originator", toRepository: originatorRepository)
        return originatorFlag()
    }
    
    fileprivate func declineByOriginator(_ receivedFlag: Flag) -> Flag {
        decline(receivedFlag, from: "originator", to: "invitee", toRepository: inviteeRepository)
        return inviteeFlag()
    }
    
    fileprivate func decline(_ receivedFlag: Flag, from: String, to: String, toRepository: FlagRepository)  {
        let invitee = receivedFlag.declining(from)
        let returnedFlag = transfer(receivedFlag)
        var calledBack = false
        toRepository.receive(from, to: to, flag: returnedFlag, onNew: { _ in XCTFail() }, onUpdate: { _ in XCTFail() }, onAck: { _ in calledBack = true })
        XCTAssertTrue(calledBack)
        receivedFlag.declineSuccess(invitee)
    }
    
    fileprivate func accept(_ receivedFlag: Flag, from: String, to: String, toRepository: FlagRepository) {
        let invitee = receivedFlag.accepting(from)
        let returnedFlag = transfer(receivedFlag)
        var calledBack = false
        toRepository.receive(from, to: to, flag: returnedFlag, onNew: { _ in XCTFail() }, onUpdate: { _ in XCTFail() }, onAck: { _ in calledBack = true })
        XCTAssertTrue(calledBack)
        receivedFlag.acceptSuccess(invitee)
    }

    fileprivate func originatorFlag() -> Flag {
        XCTAssertTrue(originatorRepository.flags().count == 1)
        return originatorRepository.flags()[0]
    }
    
    fileprivate func inviteeFlag() -> Flag {
        XCTAssertTrue(inviteeRepository.flags().count == 1)
        return inviteeRepository.flags()[0]
    }
    
    fileprivate func invitee2Flag() -> Flag {
        XCTAssertTrue(invitee2Repository.flags().count == 1)
        return invitee2Repository.flags()[0]
    }
    
    fileprivate  func transfer(_ flag: Flag) -> Flag {
        return Flag.decode(flag.encode())
    }
    
    fileprivate func event(_ id: String, description: String) -> Flag {
        return flag(id, when: Date(), description: description)
    }
    
    fileprivate func flag(_ id: String, description: String) -> Flag {
        return flag(id, when: nil, description: description)
    }
    
    fileprivate func flag(_ id: String, when: Date?, description: String) -> Flag {
        return Flag.create(id, type: "type", description: description, location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), originator: "originator", orientation: UIDeviceOrientation.faceUp, when: when)
    }
}
