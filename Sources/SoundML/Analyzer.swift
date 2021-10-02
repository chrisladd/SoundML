//
//  Analyzer.swift
//
//  Created by Christopher Ladd on 10/2/21.
//

import Foundation
import AVFoundation
import SoundAnalysis
import UIKit

/// An Analyzer object observes audio buffers, and maintains an internal ML analysis, reporting onMatch of any sound groups of interest.
@available(iOS 15.0, *)
public class Analyzer: NSObject {
    public var onUpdate: ((Bool, [SoundGroup.Match]?) -> Void)? = nil

    public let id: String
    
    public init(id: String? = nil) {
        self.id = id ?? UUID().uuidString
        analysisQueue = DispatchQueue(label: "com.soundAnalyzer.\(self.id)")
    }
    
    public var soundGroups: [SoundGroup]? = nil

    public var windowDuration: Double = 0.5
    public var preferredTimescale: CMTimeScale = 16000
    
    fileprivate var audioStreamAnalyzer: SNAudioStreamAnalyzer? = nil {
        didSet {
            if let oldValue = oldValue {
                oldValue.removeAllRequests()
            }
        }
    }
    
    fileprivate var audioFormat: AVAudioFormat? = nil
    fileprivate let analysisQueue: DispatchQueue
    
    deinit {
        audioStreamAnalyzer?.removeAllRequests()
    }
}

@available(iOS 15.0, *)
extension Analyzer {
    
    /// Appends an audio buffer, creating an internal analyzer object if needed
    ///
    /// This information is available from the tap block of an AVAudioEngine
    ///
    /// - Parameters:
    ///   - buffer: a buffer
    ///   - time: a time
    public func process(buffer: AVAudioBuffer, time: AVAudioTime) {
        // if we don't yet have an analyzer, create one
        if audioStreamAnalyzer == nil {
            createAnalyzer(format: buffer.format)
        }
        // if our audio format has somehow changed, recreate our analyzer
        else if let audioFormat = audioFormat, audioFormat.isEqual(buffer.format) == false {
            createAnalyzer(format: buffer.format)
        }
        
        analysisQueue.async { [weak self] in
            self?.audioStreamAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
    }
    
    fileprivate func createAnalyzer(format: AVAudioFormat) {
        audioStreamAnalyzer = SNAudioStreamAnalyzer(format: format)
        audioFormat = format
        let version1 = SNClassifierIdentifier.version1
        
        do {
            let request = try SNClassifySoundRequest(classifierIdentifier: version1)
            request.windowDuration = CMTime(seconds: windowDuration,
                                            preferredTimescale: preferredTimescale)
            try audioStreamAnalyzer?.add(request, withObserver: self)
        }
        catch {
            
        }
    }
}

@available(iOS 15.0, *)
extension Analyzer: SNResultsObserving {
    public func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else  { return }
        guard let containers = soundGroups else {
            return
        }
        
        let matches = containers.compactMap({ $0.matchFor(classifications: result.classifications) })
        
        if matches.count > 0 {
            onUpdate?(true, matches)
        }
        else {
            onUpdate?(false, nil)
        }
    }
    
    /// Notifies the observer when a request generates an error.
    public func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
    }

    /// Notifies the observer when a request is complete.
    public func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}
