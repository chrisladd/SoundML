//
//  Analyzer.swift
//
//  Created by Christopher Ladd on 10/2/21.
//

import Foundation
import AVFoundation
import SoundAnalysis
import UIKit

/// An Analyzer object observes audio buffers, and maintains an internal ML analysis, reporting onUpdate for any sound groups of interest.
@available(iOS 15.0, *)
public class Analyzer: NSObject {

    /// Clients can subscribe to updates after analysis is complete.
    ///
    /// The update block contains a Bool representing whether a match occurred,
    /// as well as an array of matches for any sounds that successfully matched.
    ///
    public var onUpdate: ((Bool, [SoundGroup.Match]?) -> Void)? = nil

    /// Informs clients of any errors in processing or setup.
    public var onError: ((Error) -> Void)? = nil
    
    /// A unique identifier for this analyzer.
    public let id: String

    /// Initializes an analyzer, with an optional identifier
    /// - Parameter id: an identifier
    public init(id: String? = nil) {
        self.id = id ?? UUID().uuidString
        analysisQueue = DispatchQueue(label: "com.soundAnalyzer.\(self.id)")
    }
    
    /// An array of sound groups a client is interested in.
    ///
    /// Successful matches will be reported in the `onUpdate` handler
    ///
    public var soundGroups: [SoundGroup]? = nil

    /// The window duration, in seconds, for audio analysis.
    ///
    /// Shorter windows will be more responsive, longer windows will likely have more fidelity
    ///
    public var windowDuration: Double = 0.5
    
    /// The preferred timescale.
    ///
    /// This is an internal denominator for the CMTime used by the underlying SNClassifySoundRequest, and can likely be left at its default value.
    ///
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
            onError?(error)
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
    ///
    /// Tear down our analyzer, we'll recreate it later if possible
    public func request(_ request: SNRequest, didFailWithError error: Error) {
        audioStreamAnalyzer?.removeAllRequests()
        audioStreamAnalyzer = nil
        
        onError?(error)
    }

    /// Notifies the observer when a request is complete.
    ///
    /// Tear down our analyzer, we'll recreate it later if possible / necessary
    public func requestDidComplete(_ request: SNRequest) {
        audioStreamAnalyzer?.removeAllRequests()
        audioStreamAnalyzer = nil
    }
}
