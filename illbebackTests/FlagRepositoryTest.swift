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
    private let repository = FlagRepository()

    func testEvents() {
        repository.add(event("an event"))
        repository.add(flag("not an event"))
        let events = repository.events()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].description(), "an event")
    }
    
    func testImminentEvents() {
        repository.add(flag(NSDate(), description: "today event"))
        repository.add(flag(NSDate.distantFuture(), description: "distant event"))
        let events = repository.imminentEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].description(), "today event")
    }
    
    func testPurgeRemovesOldEvents() {
        repository.add(flag(nil, description: "non event"))
        repository.add(flag(NSDate(), description: "today event"))
        repository.add(flag(NSDate.distantPast(), description: "past event"))
        repository.add(flag(NSDate.distantFuture(), description: "future event"))
        repository.purge()
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 3)
        XCTAssertEqual(flags[0].description(), "non event")
        XCTAssertEqual(flags[1].description(), "today event")
        XCTAssertEqual(flags[2].description(), "future event")
    }
    
    func testFind() {
        repository.add(flag("a flag"))
        XCTAssertEqual(repository.find("id")?.description(), "a flag")
    }
    
    func testFindFails() {
        XCTAssertEqual(repository.find("unknown"), nil)
    }
    
    func testAdd() {
        repository.add(flag("a flag"))
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "a flag")
    }
    
    func testRemove() {
        let flag1 = flag("a flag")
        repository.add(flag1)
        repository.remove(flag1)
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 0)
    }
    
    func testDeadFlagsIgnored() {
        let flag1 = flag("a flag")
        repository.add(flag1)
        flag1.kill()
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 0)
    }
    
    func testDeadEventsIgnored() {
        let event1 = event("a flag")
        repository.add(event1)
        event1.kill()
        let events = repository.events()
        XCTAssertEqual(events.count, 0)
    }
    
    func testReceiveNewForwardedChangesOriginator() {
        let flag1 = flag("a flag")
        repository.receive("Spencer", flag: flag1, onNew: { }, onUpdate: { }, onAck: { })
        let flags = repository.flags()
        XCTAssertEqual(flags[0].originator(), "Spencer")
    }
    
    func testReceiveUpdateForwardedLeavesOriginator() {
        let flag1 = flag("a flag")
        repository.add(flag1)
        let flag2 = flag("an updated flag")
        flag2.invite("Madeleine")
        repository.receive("Spencer", flag: flag2, onNew: { }, onUpdate: { }, onAck: { })
        let flags = repository.flags()
        XCTAssertEqual(flags[0].originator(), "originator")
    }
    
    func testReceiveUpdateForwardedLeavesInvitees() {
        let flag1 = flag("a flag")
        flag1.invite("Madeleine")
        repository.add(flag1)
        let flag2 = flag("an updated flag")
        flag2.invite("Leon")
        repository.receive("Spencer", flag: flag2, onNew: { }, onUpdate: { }, onAck: { })
        let flags = repository.flags()
        XCTAssertEqual(flags[0].invitees().count, 1)
        XCTAssertEqual(flags[0].invitees()[0].name(), "Madeleine")
    }
    
    func testReceiveNew() {
        var calledBack = false
        let flag1 = flag("a flag")
        flag1.invite("Madeleine")
        repository.receive("Madeleine", flag: flag1, onNew: { calledBack = true }, onUpdate: { XCTFail() }, onAck: { XCTFail() })
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "a flag")
        XCTAssertEqual(flags[0].state(), FlagState.ReceivingNew)
        XCTAssertEqual(flags[0].invitees()[0].name(), "Madeleine")
        XCTAssertEqual(flags[0].invitees()[0].state(), InviteeState.Invited)
        XCTAssertTrue(calledBack)
    }
    
    func testReceiveUpdate() {
        var calledBack = false
        let flag1 = flag("a flag")
        repository.add(flag1)
        let flag2 = flag("an updated flag")
        flag2.invite("Madeleine")
        repository.receive("Madeleine", flag: flag2, onNew: { XCTFail() }, onUpdate: { calledBack = true }, onAck: { XCTFail() })
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "an updated flag")
        XCTAssertEqual(flags[0].state(), FlagState.ReceivingUpdate)
        XCTAssertTrue(calledBack)
    }
    
    func testReceiveAcceptNewAck() {
        var calledBack = false
        let offeredFlag = flag("a flag")
        repository.add(offeredFlag)
        offeredFlag.invite("Madeleine")
        let acceptedFlag = Flag.decode(offeredFlag.encode())
        try! acceptedFlag.receivingNew("Madeleine")
        try! acceptedFlag.receiveNewSuccess()
        acceptedFlag.accepting("Madeleine")
        repository.receive("Madeleine", flag: acceptedFlag, onNew: { XCTFail() }, onUpdate: { XCTFail() }, onAck: { calledBack = true })
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "a flag")
        XCTAssertEqual(flags[0].state(), FlagState.Neutral)
        XCTAssertEqual(flags[0].invitees().count, 1)
        XCTAssertEqual(flags[0].invitees()[0].name(), "Madeleine")
        XCTAssertEqual(flags[0].invitees()[0].state(), InviteeState.Accepted)
        XCTAssertTrue(calledBack)
    }
    
    func testReceiveDeclineNewAck() {
        var calledBack = false
        let offeredFlag = flag("a flag")
        repository.add(offeredFlag)
        offeredFlag.invite("Madeleine")
        let declinedFlag = Flag.decode(offeredFlag.encode())
        try! declinedFlag.receivingNew("Madeleine")
        try! declinedFlag.receiveNewSuccess()
        declinedFlag.declining("Madeleine")
        repository.receive("Madeleine", flag: declinedFlag, onNew: { XCTFail() }, onUpdate: { XCTFail() }, onAck: { calledBack = true })
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "a flag")
        XCTAssertEqual(flags[0].state(), FlagState.Neutral)
        XCTAssertEqual(flags[0].invitees().count, 1)
        XCTAssertEqual(flags[0].invitees()[0].name(), "Madeleine")
        XCTAssertEqual(flags[0].invitees()[0].state(), InviteeState.Declined)
        XCTAssertTrue(calledBack)
    }

    func testReceiveAcceptNewAckWhenOriginalFlagHasBeenRemoved() {
        var calledBackForNew = false
        var calledBackForAck = false
        let offeredFlag = flag("a flag")
        let offeringRepository = FlagRepository()
        offeredFlag.invite("Receiver")
        offeringRepository.add(offeredFlag)
        offeringRepository.remove(offeredFlag)
        
        let receivingRepository = FlagRepository()
        let receivedFlag = Flag.decode(offeredFlag.encode())
        receivingRepository.receive("Offererer", flag: receivedFlag, onNew: {}, onUpdate: {}, onAck: {})
        try! receivedFlag.receiveNewSuccess()
        receivedFlag.accepting("Receiver")
        
        offeringRepository.receive("Receiver", flag: Flag.decode(receivedFlag.encode()), onNew: {  calledBackForNew = true }, onUpdate: { XCTFail() }, onAck: { calledBackForAck = true })

        let flags = offeringRepository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "a flag")
        XCTAssertEqual(flags[0].state(), FlagState.ReceivingNew)
        XCTAssertEqual(flags[0].invitees().count, 1)
        XCTAssertEqual(flags[0].invitees()[0].name(), "Receiver")
        XCTAssertEqual(flags[0].invitees()[0].state(), InviteeState.Accepted)
        XCTAssertTrue(calledBackForNew)
        XCTAssertTrue(calledBackForAck)
    }
    
    func testReceiveAcceptUpdateAckWhenOriginalFlagHasBeenRemoved() {
        var calledBackForNew = false
        var calledBackForAck = false
        let offeredFlag = flag("a flag")
        repository.add(offeredFlag)
        offeredFlag.invite("Madeleine")
        let acceptedFlag = Flag.decode(offeredFlag.encode())
        acceptedFlag.receivingUpdate(Flag.decode(offeredFlag.encode()))
        try! acceptedFlag.receiveUpdateSuccess()
        acceptedFlag.accepting("Madeleine")
        repository.remove(offeredFlag)
        repository.receive("Madeleine", flag: acceptedFlag, onNew: { calledBackForNew = true }, onUpdate: { XCTFail() }, onAck: { calledBackForAck = true })
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "a flag")
        XCTAssertEqual(flags[0].state(), FlagState.ReceivingNew)
        XCTAssertEqual(flags[0].invitees().count, 1)
        XCTAssertEqual(flags[0].invitees()[0].name(), "Madeleine")
        XCTAssertEqual(flags[0].invitees()[0].state(), InviteeState.Accepted)
        XCTAssertTrue(calledBackForNew)
        XCTAssertTrue(calledBackForAck)
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