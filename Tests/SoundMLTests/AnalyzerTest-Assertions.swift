//
//  XCTestCase-SoundMLAssertions.swift
//  
//
//  Created by Christopher Ladd on 10/14/21.
//

import Foundation
@testable import SoundML
import XCTest


@available(iOS 15.0, *)
extension AnalyzerTest {
    func assertGroup(group: SoundGroup, matches fixture: String) {
        let expectation = XCTestExpectation(description: "group \(group.id) matches \(fixture)")
        guard let buffers = buffersForFixture(label: fixture) else { XCTFail(); return }
        XCTAssertGreaterThan(buffers.count, 0)
        
        analyzer.soundGroups = [
            group
        ]
        
        analyzer.onUpdate = { isMatch, matches in
            guard let matches = matches else { return }
            guard matches.contains(where: { $0.group.id == group.id }) else { return }
            expectation.fulfill()
        }
        
        analyzer.process(buffers: buffers)
        
        wait(for: [expectation], timeout: 1)    }
    
    func assertGroup(group: SoundGroup, doesNotMatch fixture: String, timeoutInterval: TimeInterval = 2) {
        let expectation = XCTestExpectation(description: "group \(group.id) does not match \(fixture)")
        guard let buffers = buffersForFixture(label: fixture) else { XCTFail(); return }
        XCTAssertGreaterThan(buffers.count, 0)
        
        analyzer.soundGroups = [
            group
        ]
        
        analyzer.onUpdate = { isMatch, matches in
            guard let matches = matches else { return }
            if matches.contains(where: { $0.group.id == group.id }) {
                XCTFail()
            }
        }
        
        analyzer.process(buffers: buffers)
        
        // Naiively assume that if we've waited half of our timeout interval without
        // encountering a match, that no match will be encountered
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutInterval / 2) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: timeoutInterval)
    }
    
}
