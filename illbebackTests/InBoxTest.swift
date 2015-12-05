//
//  InBoxTest.swift
//  illbeback
//
//  Created by Spencer Ward on 05/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import XCTest

class InBoxTest: XCTestCase {
    var inBox: InBox!
    var flagRepository: FlagRepository!
    var photoAlbum: PhotoAlbum!
    
    override func setUp() {
        super.setUp()
        flagRepository = FlagRepository()
        photoAlbum = PhotoAlbum()
        inBox = InBox(flagRepository: flagRepository, photoAlbum: photoAlbum)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
