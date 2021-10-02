//
//  SoundGroup.swift
//
//  Created by Christopher Ladd on 10/2/21.
//

import Foundation
import SoundAnalysis

public struct SoundGroup {
    public let id: String
    public let sounds: [Sound]

    public struct Match {
        public let group: SoundGroup
        public let sound: Sound
        public let confidence: Double
    }
    
    public init(id: String? = nil, sounds: [Sound]) {
        self.id = id ?? UUID().uuidString
        self.sounds = sounds
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
