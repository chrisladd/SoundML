//
//  Analyzer-MultipleBuffers.swift
//  
//
//  Created by Christopher Ladd on 10/14/21.
//

import Foundation
import AVFoundation
@testable import SoundML

@available(iOS 15.0, *)
extension Analyzer {
    func process(buffers: [AVAudioPCMBuffer]) {
        var sampleOffset: AVAudioFramePosition = 0
        let sampleRate = buffers.first!.format.sampleRate
        for buffer in buffers {
            process(buffer: buffer, time: AVAudioTime.init(sampleTime: sampleOffset, atRate: sampleRate))
            sampleOffset += AVAudioFramePosition(buffer.frameLength)
        }
    }
}
