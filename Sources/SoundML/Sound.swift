//
//  Sound.swift
//
//  Created by Christopher Ladd on 10/2/21.
//

import Foundation
import SoundAnalysis

public struct Sound {
    public let label: String
    public let threshold: Double
    
    public init(label: String, threshold: Double) {
        self.label = label
        self.threshold = threshold
    }
    
    public init(_ type: SoundType, threshold: Double) {
        self.label = type.rawValue
        self.threshold = threshold
    }
    
}

@available(iOS 13.0, *)
extension Sound {
    func matches(classification: SNClassification) -> Bool {
        guard label == classification.identifier else { return false }
        guard classification.confidence >= threshold else { return false }
        return true
    }

}
