import Foundation

// Adapted from https://github.com/keith-turner/ecoji/blob/master/docs/encoding.md

public enum EncodingError: Error {
    case UnexpectedEndOfInput
    case InvalidCharacter(found: Character)
}

public class EcojiEncoder {
    public init() {}
    
    public func encode(from str: String) -> String? {
        if let data = str.data(using: .utf8) {
            return encode(from: data)
        }
        return nil
    }
    
    public func encode(from data: Data) -> String {
        let dataStream = InputStream(data: data)
        dataStream.open()
        
        let numBytesPerObject = 5
        var buffer = [UInt8](repeating: 0, count: numBytesPerObject)
        var output = [Character]()
        
        var numRead = dataStream.read(&buffer, maxLength: numBytesPerObject)
        while numRead != 0 {
            let b0: Int = Int(buffer[0])
            var b1: Int = 0
            var b2: Int = 0
            var b3: Int = 0
            var b4: Int = 0
            
            if numRead > 1 {
                b1 = Int(buffer[1])
            }
            
            if numRead > 2 {
                b2 = Int(buffer[2])
            }
            
            if numRead > 3 {
                b3 = Int(buffer[3])
            }
            
            if numRead > 4 {
                b4 = Int(buffer[4])
            }
            
            // use 8 bits from 1st byte and 2 bits from 2nd byte to lookup emoji
            output.append(emojis[b0<<2 | b1>>6])
            
            switch (numRead) {
            case 1:
                output.append(padding)
                output.append(padding)
                output.append(padding)
            case 2:
                output.append(emojis[(b1 & 0x3f)<<4 | b2>>4])
                output.append(padding)
                output.append(padding)
            case 3:
                output.append(emojis[(b1 & 0x3f)<<4 | b2>>4])
                output.append(emojis[(b2 & 0x0f)<<6 | b3>>2])
                output.append(padding)
            case 4:
                output.append(emojis[(b1 & 0x3f)<<4 | b2>>4])
                output.append(emojis[(b2 & 0x0f)<<6 | b3>>2])
                
                //look at last two bits of 4th byte to determine padding to use
                switch (b3 & 0x03) {
                case 0:
                    output.append(padding40)
                case 1:
                    output.append(padding41)
                case 2:
                    output.append(padding42)
                case 3:
                    output.append(padding43)
                default:
                    // This cannot happen
                    break
                }
            case 5:
                // use 6 bits from 2nd byte and 4 bits from 3rd byte to lookup emoji
                output.append(emojis[(b1 & 0x3f)<<4 | b2>>4])
                // use 4 bits from 3rd byte and 6 bits from 4th byte to lookup emoji
                output.append(emojis[(b2 & 0x0f)<<6 | b3>>2])
                //user 2 bits from 4th byte and 8 bits from 5th byte to lookup emoji
                output.append(emojis[(b3 & 0x03)<<8 | b4]);
            default:
                // This cannot happen
                break
            }
            numRead = dataStream.read(&buffer, maxLength: numBytesPerObject)
        }
        return String(output)
    }
}

public enum DecodingError: Error {
    case UnexpectedEndOfInput
    case InvalidCharacter(found: Character)
}

public class EcojiDecoder {
    public init() {}
    
    private func getEmojiIndex(for char: Character) throws -> Int {
        if let index = revEmojis[char] {
            return index
        } else if char == padding || char == padding40 || char == padding41 || char == padding42 || char == padding43 {
            return 0
        }
        throw DecodingError.InvalidCharacter(found: char)
    }
    
    public func decode(string input: String) throws -> Data {
        var index = 0
        let source = Array(input)
        var buffer = [Character](repeating: " ", count: 4)
        var outputBytes = Array<UInt8>()
        
        while index < input.count {
            buffer[0] = source[index]

            for i in 1...3 {
                index += 1
                if index >= input.count {
                    throw DecodingError.UnexpectedEndOfInput
                }
                buffer[i] = source[index]
            }
            // increment for next round
            index += 1

            let bits1 = try getEmojiIndex(for: buffer[0])
            let bits2 = try getEmojiIndex(for: buffer[1])
            let bits3 = try getEmojiIndex(for: buffer[2])
            var bits4: Int = 0

            switch buffer[3] {
            case padding40:
                bits4 = 0
            case padding41:
                bits4 = 1 << 8
            case padding42:
                bits4 = 2 << 8
            case padding43:
                bits4 = 3 << 8
            default:
                bits4 = try getEmojiIndex(for: buffer[3])
            }

            var out = Array<UInt8>(repeating: 0, count: 5)
            out[0] = UInt8(bits1 >> 2)
            out[1] = UInt8(((bits1 & 0x3) << 6) | (bits2 >> 4))
            out[2] = UInt8(((bits2 & 0xf) << 4) | (bits3 >> 6))
            out[3] = UInt8(((bits3 & 0x3f) << 2) | (bits4 >> 8))
            out[4] = UInt8(bits4 & 0xff)

            var ending = 5
            if buffer[1] == padding {
                ending = 1
            } else if buffer[2] == padding{
                ending = 2
            } else if buffer[3] == padding {
                ending = 3
            } else if buffer[3] == padding40 || buffer[3] == padding41 || buffer[3] == padding42 || buffer[3] == padding43 {
                // this is useless logic
                ending = 4
            }
            outputBytes.append(contentsOf: out.prefix(ending))
        }
        return Data(bytes: outputBytes, count: outputBytes.count)
    }
    
    public func decodeToString(string input: String) throws -> String {
        let output = try self.decode(string: input)
        return String(decoding: output, as: UTF8.self)
    }
}
