//
//  FlagTokenTest.swift
//  illbeback
//
//  Created by Spencer Ward on 04/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import XCTest
import CoreLocation

class FlagTokenTest: XCTestCase {
    var token: FlagToken?
    var decoded: FlagToken?

    
    func testEncodesInvitees() {
        setUpWithUpdate()
        XCTAssertEqual(token!.invitees()[0].name(), decoded!.invitees()[0].name())
    }
    
    func testEncodesInviteesUpdate() {
        setUpWithUpdate()
        XCTAssertEqual(token!.inviteesUpdate()![0].name(), decoded!.inviteesUpdate()![0].name())
    }
    
    func testEncodesOriginator() {
        setUpWithUpdate()
        XCTAssertEqual(token!.originator(), decoded!.originator())
    }
    
    func testEncodesState() {
        setUpWithUpdate()
        XCTAssertEqual(token!.state(), decoded!.state())
    }
    
    func testEncodesType() {
        setUpWithUpdate()
        XCTAssertEqual(token!.type(), decoded!.type())
    }
    
    func testEncodesDescription() {
        setUpWithUpdate()
        XCTAssertEqual(token!.description(), decoded!.description())
    }
    
    func testEncodesDescriptionUpdate() {
        setUpWithUpdate()
        XCTAssertEqual(token!.descriptionUpdate()!, decoded!.descriptionUpdate()!)
    }
    
    func testEncodesLocation() {
        setUpWithUpdate()
        XCTAssertEqual(token!.location().latitude, decoded!.location().latitude)
        XCTAssertEqual(token!.location().longitude, decoded!.location().longitude)
    }
    
    func testEncodesLocationUpdate() {
        setUpWithUpdate()
        XCTAssertEqual(token!.locationUpdate()!.latitude, decoded!.locationUpdate()!.latitude)
        XCTAssertEqual(token!.locationUpdate()!.longitude, decoded!.locationUpdate()!.longitude)
    }
    
    func testEncodesWhen() {
        setUpWithUpdate()
        XCTAssertEqualWithAccuracy(token!.when()!.timeIntervalSince1970, decoded!.when()!.timeIntervalSince1970, accuracy: 0.01)
    }
    
    func testEncodesWhenUpdate() {
        setUpWithUpdate()
        XCTAssertEqualWithAccuracy(token!.whenUpdate()!.timeIntervalSince1970, decoded!.whenUpdate()!.timeIntervalSince1970, accuracy: 0.01)
    }
    
    func testEncodesInviteesWhenNoUpdate() {
        setUpWithoutUpdate()
        XCTAssertEqual(token!.invitees()[0].name(), decoded!.invitees()[0].name())
    }
    
    func testEncodesInviteesUpdateWhenNoUpdate() {
        setUpWithoutUpdate()
        XCTAssertTrue(token!.inviteesUpdate() == nil)
        XCTAssertTrue(decoded!.inviteesUpdate() == nil)
    }
    
    func testEncodesDescriptionWhenNoUpdate() {
        setUpWithoutUpdate()
        XCTAssertEqual(token!.description(), decoded!.description())
    }
    
    func testEncodesDescriptionUpdateWhenNoUpdate() {
        setUpWithoutUpdate()
        XCTAssertEqual(token!.descriptionUpdate(), decoded!.descriptionUpdate())
    }
    
    func testEncodesLocationWhenNoUpdate() {
        setUpWithoutUpdate()
        XCTAssertEqual(token!.location().latitude, decoded!.location().latitude)
        XCTAssertEqual(token!.location().longitude, decoded!.location().longitude)
    }
    
    func testEncodesLocationUpdateWhenNoUpdate() {
        setUpWithoutUpdate()
        XCTAssertEqual(token!.locationUpdate()?.latitude, decoded!.locationUpdate()?.latitude)
        XCTAssertEqual(token!.locationUpdate()?.longitude, decoded!.locationUpdate()?.longitude)
    }
    
    func testEncodesWhenWhenNoUpdate() {
        setUpWithoutUpdate()
        XCTAssertEqualWithAccuracy(token!.when()!.timeIntervalSince1970, decoded!.when()!.timeIntervalSince1970, accuracy: 0.01)
    }
    
    func testEncodesWhenUpdateWhenNoUpdate() {
        setUpWithoutUpdate()
        XCTAssertEqual(token!.whenUpdate()?.timeIntervalSince1970, decoded!.whenUpdate()?.timeIntervalSince1970)
    }
    
    func testEncodesBlankDescriptionWhenUpdate() {
        token = createTokenWithoutUpdates()
        token?.description("")
        let encoded = token!.encode()
        decoded = FlagToken(token: encoded)
        XCTAssertEqual(token!.description(), decoded!.description())
    }
    
    func testEncodesBlankDescriptionUpdateWhenUpdate() {
        token = createTokenWithoutUpdates()
        let updateToken = createTokenWithoutUpdates()
        updateToken.description("")
        token?.pendingUpdate(updateToken)
        let encoded = token!.encode()
        decoded = FlagToken(token: encoded)
        XCTAssertEqual(token!.descriptionUpdate(), decoded!.descriptionUpdate())
    }
    
    private func setUpWithUpdate() {
        token = createTokenWithUpdates()
        let encoded = token!.encode()
        decoded = FlagToken(token: encoded)
    }
    
    private func setUpWithoutUpdate() {
        token = createTokenWithoutUpdates()
        let encoded = token!.encode()
        decoded = FlagToken(token: encoded)
    }

    private func createTokenWithUpdates() -> FlagToken {
        let token = createTokenWithoutUpdates()
        let updateToken = FlagToken(id: "id", state: FlagState.Neutral, type: "type", description: "updated description", location: CLLocationCoordinate2D(latitude: 3.0, longitude: 4.0), originator: "originator", orientation: UIDeviceOrientation.FaceUp, when: NSDate.distantFuture())
        updateToken.addInvitee(Invitee2(name: "Spencer"))
        token.pendingUpdate(updateToken)
        return token
    }

    private func createTokenWithoutUpdates() -> FlagToken {
        let token = FlagToken(id: "id", state: FlagState.Neutral, type: "type", description: "description", location: CLLocationCoordinate2D(latitude: 1.0, longitude: 2.0), originator: "originator", orientation: UIDeviceOrientation.FaceUp, when: NSDate())
        token.addInvitee(Invitee2(name: "Madeleine"))
        return token
    }
}
