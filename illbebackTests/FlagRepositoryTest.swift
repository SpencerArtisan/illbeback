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
        repository.add(nonEvent("not an event"))
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
    
    func testDelete() {
        // todo
    }
    
    private func event(description: String) -> Flag {
        return flag(NSDate(), description: description)
    }
    
    private func nonEvent(description: String) -> Flag {
        return flag(nil, description: description)
    }
    
    private func flag(when: NSDate?, description: String) -> Flag {
        return Flag.create("id", type: "type", description: description, location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), originator: "originator", orientation: UIDeviceOrientation.FaceUp, when: when)
    }
}