//
//  SimpleAudioTests.swift
//  FlashAudio
//
//  Created by Serena Chan on 13/5/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import XCTest
@testable import FlashAudio

class SimpleAudioTests: XCTestCase {
    
    var audioRecorder:AudioRecorder?
    var audioPlayer:AudioPlayer?
    
    override func setUp() {
        super.setUp()
        audioRecorder = AudioRecorder()
        audioPlayer = AudioPlayer()
    }
    
    override func tearDown() {
        super.tearDown()
        audioRecorder = nil
        audioPlayer = nil
    }
    
    func testRecorder1() throws{
        
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}

