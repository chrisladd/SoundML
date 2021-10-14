//
//  Sound.swift
//
//  Created by Christopher Ladd on 10/2/21.
//

import Foundation
import SoundAnalysis

/// A Sound object represents a specific ML recognition.
///
/// It contains both an applicable label, as well as the threshold above which a match should be considered "good enough".
///
public struct Sound {
    
    /// The label associated with the matched sound. See `SoundType` for available values.
    public let label: String
    
    
    /// The threshold, from 0.0 to 1.0, above which a label should be considered to be matched.
    public let threshold: Double

    /// Creates a Sound, given a type and a threshold value
    /// - Parameters:
    ///   - type: a type. See `SoundType` for available values.
    ///   - threshold: a threshold value, from 0.0 to 1.0
    public init(_ type: SoundType, threshold: Double) {
        self.label = type.rawValue
        self.threshold = threshold
    }
    
    /// Creates a Sound, given a label and a threshold value
    /// - Parameters:
    ///   - label: a label. See `SoundType` for available values.
    ///   - threshold: a threshold value, from 0.0 to 1.0
    public init(label: String, threshold: Double) {
        self.label = label
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
