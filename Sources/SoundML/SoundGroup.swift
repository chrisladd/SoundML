//
//  SoundGroup.swift
//
//  Created by Christopher Ladd on 10/2/21.
//

import Foundation
import SoundAnalysis


/// A SoundGroup represents one or more Sound objects, any of which matching above their threshold consitutes a match.
///
/// This allows clients to target multiple sounds with the same semantic meaning. For example, a SoundGroup might target both `nose_blowing` and `slurp`, with respective thresholds, under the id of `rudeness`.
///
public struct SoundGroup {
    
    /// An id to uniquely identify this SoundGroup
    public let id: String
        
    /// An array of sounds, any of which constitutes a match.
    public let sounds: [Sound]

    /// A match object, passed back to the client on any matched groups.
    public struct Match {
        
        /// The group that matched
        public let group: SoundGroup
        
        /// The sound within the group that matched most highly.
        public let sound: Sound
        
        /// The confidence that this sound was actually detected.
        ///
        /// This value will, by definition, by greater than the `threshold` of `sound`.
        public let confidence: Double
    }
    
    
    /// Initializes a group with an id and an array of sounds, any of which would constitute a match.
    /// - Parameters:
    ///   - id: an identifier
    ///   - sounds: an array of sounds
    public init(id: String? = nil, sounds: [Sound]) {
        self.id = id ?? UUID().uuidString
        self.sounds = sounds
    }
    
    /// Initializes a group with a single sound type and threshold.
    ///
    /// The group's id will be derived automatically from the raw value of the sound type, and the array of sounds will be created from a single sound of that type.
    ///
    /// - Parameters:
    ///   - soundType: a sound type
    ///   - threshold: a threshold
    public init(_ soundType: SoundType, threshold: Double) {
        let sound = Sound(soundType, threshold: threshold)
        self.id = soundType.rawValue
        self.sounds = [sound]
    }
    
}

@available(iOS 15.0, *)
extension SoundGroup {
    func matchFor(classifications: [SNClassification]) -> SoundGroup.Match? {
        for classification in classifications {
            guard let sound = sounds.first(where: { $0.matches(classification: classification) }) else { continue }
            
            return SoundGroup.Match(group: self,
                                   sound: sound,
                                   confidence: classification.confidence)
        }
        
        return nil
    }
}
