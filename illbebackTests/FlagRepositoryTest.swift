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
    
    func testReceiveNew() {
        var calledBack = false
        let flag1 = flag("a flag")
        flag1.invite("Madeleine")
        repository.receive(flag1, onNew: { calledBack = true }, onUpdate: { XCTFail() }, onAck: { XCTFail() })
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "a flag")
        XCTAssertEqual(flags[0].state(), FlagState.NewOffered)
        XCTAssertTrue(calledBack)
    }
    
    func testReceiveUpdate() {
        var calledBack = false
        let flag1 = flag("a flag")
        repository.add(flag1)
        let flag2 = flag("an updated flag")
        flag2.invite("Madeleine")
        repository.receive(flag2, onNew: { XCTFail() }, onUpdate: { calledBack = true }, onAck: { XCTFail() })
        let flags = repository.flags()
        XCTAssertEqual(flags.count, 1)
        XCTAssertEqual(flags[0].description(), "an updated flag")
        XCTAssertEqual(flags[0].state(), FlagState.UpdateOffered)
        XCTAssertTrue(calledBack)
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