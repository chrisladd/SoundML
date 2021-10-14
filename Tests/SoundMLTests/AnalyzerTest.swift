//
//  AnalyzerTest.swift
//  
//
//  Created by Christopher Ladd on 10/14/21.
//

import Foundation
@testable import SoundML
import XCTest

protocol AnalyzerTest: XCTestCase {
    @available(iOS 15.0, *)
    var analyzer: Analyzer { get set }
}
