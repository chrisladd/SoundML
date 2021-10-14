//
//  AVAudioPCMBuffer-File.swift
//  
//
//  Created by Christopher Ladd on 10/14/21.
//

import Foundation
import AVFoundation

extension AVAudioPCMBuffer {
    static func buffersForFileAtPath(_ path: String, bufferLength: Int) -> [AVAudioPCMBuffer]? {
        let url = URL(fileURLWithPath: path)
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        
        let bufferLength = Int(bufferLength)
        var currentPosition = 0

        var buffers = [AVAudioPCMBuffer]()
        
        while currentPosition + bufferLength < file.length {
            guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: UInt32(file.length)) else { continue }
            
            // set the frame position
            file.framePosition = AVAudioFramePosition(currentPosition)
            
            do {
                try file.read(into: buffer, frameCount: AVAudioFrameCount(bufferLength))
                buffers.append(buffer)
            }
            catch {
                print("Error reading file at \(file) into buffer")
            }
            
            currentPosition += bufferLength
        }
        
        if buffers.count == 0 {
            return nil
        }
        
        return buffers
    }

    
}

