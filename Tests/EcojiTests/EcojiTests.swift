import XCTest
import class Foundation.Bundle
import Ecoji

final class EcojiTests: XCTestCase {

    func testEncodeString() throws {
      let encoder = EcojiEncoder()
      let output = encoder.encode(from: "Hello World!")
      XCTAssertEqual(output, "🏯🔩🚗🌷🍉👇🦒🕊👡📢☕☕")
    }
    
    func testEncodeData() throws {
        let encoder = EcojiEncoder()
        let output = encoder.encode(from: "Hello World!".data(using: .utf8)!)
        XCTAssertEqual(output, "🏯🔩🚗🌷🍉👇🦒🕊👡📢☕☕")
    }
    
    func testDecodeData() throws {
        let decoder = EcojiDecoder()
        let output = try decoder.decode(string: "🏯🔩🚗🌷🍉👇🦒🕊👡📢☕☕")
        XCTAssertEqual(String(decoding: output, as: UTF8.self), "Hello World!")
    }
    
    func testDecodeString() throws {
        let decoder = EcojiDecoder()
        let output = try decoder.decodeToString(string: "🏯🔩🚗🌷🍉👇🦒🕊👡📢☕☕")
        XCTAssertEqual(output, "Hello World!")
    }
    
    func testDecodeDataWithBadEmoji() throws {
        let decoder = EcojiDecoder()
        do {
            let _ = try decoder.decode(string: "🏯🔩🚗🌷🍉👇🦒🕊👡🏴‍☠️☕☕")
            XCTFail()
        } catch let err as DecodingError {
            switch err {
            case .UnexpectedEndOfInput:
                XCTFail()
            case .InvalidCharacter(let found):
                XCTAssertEqual(found, "🏴‍☠️")
            }
        }
    }
    
    func testDecodeDataWithBadLength() throws {
        let decoder = EcojiDecoder()
        do {
            let _ = try decoder.decode(string: "🏯🔩🚗🌷🍉👇🦒🕊👡📢☕")
            XCTFail()
        } catch let err as DecodingError {
            switch err {
            case .UnexpectedEndOfInput:
                break
            case .InvalidCharacter(_):
                XCTFail()
            }
        }
    }
        
    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testEncodeString", testEncodeString),
        ("testEncodeData", testEncodeData),
        ("testDecodeString", testDecodeString),
        ("testEncodeData", testDecodeData),
        ("testEncodeData", testDecodeDataWithBadEmoji),
        ("testEncodeData", testDecodeDataWithBadLength),
    ]
}
