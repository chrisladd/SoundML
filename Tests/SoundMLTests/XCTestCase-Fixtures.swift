//
//  XCTestCase-Fixtures.swift
//  
//
//  Created by Christopher Ladd on 10/14/21.
//

import Foundation
import AVFoundation
import XCTest

extension XCTestCase {
    func pathForFixture(label: String) -> String? {
        return Bundle.module.path(forResource: label, ofType: "aiff", inDirectory: "fixtures")
    }
    
    func buffersForFixture(label: String, bufferLength: Int = 2048) -> [AVAudioPCMBuffer]? {
        guard let path = pathForFixture(label: label) else { return nil }
        return AVAudioPCMBuffer.buffersForFileAtPath(path, bufferLength: bufferLength)
    }
}

