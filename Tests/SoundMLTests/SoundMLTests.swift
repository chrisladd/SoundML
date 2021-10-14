import XCTest
@testable import SoundML
import AVFAudio

@available(iOS 15.0, *)
final class SoundMLTests: XCTestCase, AnalyzerTest {
    var analyzer = Analyzer()
    
    override func setUp() {
        super.setUp()
        // start with a fresh analyzer for each test.
        // because an analyzer consumes samples in an "asynchronous" way,
        // prior samples fed into the analyzer may later be interpreted
        // when you think your later samples are being processed.
        analyzer = Analyzer()
    }
    
    func testClapping() {
        assertGroup(group: SoundGroup(.clapping, threshold: 0.7),
                    matches: "clap")
    }
    
    func testClappingDoesNotMatchWhenNotExpected() {
        assertGroup(group: SoundGroup(.clapping, threshold: 0.5),
                    doesNotMatch: "guitar")
    }

    func testGuitarMatchesExpected() {
        assertGroup(group: SoundGroup(.guitar, threshold: 0.6),
                    matches: "guitar")
    }
    
    func testGuitarDoesNotMatchWhenNotExpected() {
        assertGroup(group: SoundGroup(.guitar, threshold: 0.6),
                    doesNotMatch: "clap")
    }

    func testSpeech() {
        assertGroup(group: SoundGroup(.speech, threshold: 0.9),
                    matches: "speech")
    }
    
    func testSpeechNotMatching() {
        assertGroup(group: SoundGroup(.speech, threshold: 0.5),
                    doesNotMatch: "guitar")
    }
    
    
}
