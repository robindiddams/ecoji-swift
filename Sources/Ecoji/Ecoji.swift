//
//  Ecoji.swift
//  lyrebird
//
//  Created by Robin Diddams on 3/27/19.
//  Copyright © 2019 Robin Diddams. All rights reserved.
//

import Foundation

// Adapted from https://github.com/keith-turner/ecoji/blob/master/docs/encoding.md

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
                break;
            case 2:
                output.append(emojis[(b1 & 0x3f)<<4 | b2>>4])
                output.append(padding)
                output.append(padding)
                break;
            case 3:
                output.append(emojis[(b1 & 0x3f)<<4 | b2>>4])
                output.append(emojis[(b2 & 0x0f)<<6 | b3>>2])
                output.append(padding)
                break;
            case 4:
                output.append(emojis[(b1 & 0x3f)<<4 | b2>>4])
                output.append(emojis[(b2 & 0x0f)<<6 | b3>>2])
                
                //look at last two bits of 4th byte to determine padding to use
                switch (b3 & 0x03) {
                case 0:
                    output.append(padding40)
                    break;
                case 1:
                    output.append(padding41)
                    break;
                case 2:
                    output.append(padding42)
                    break;
                case 3:
                    output.append(padding43)
                    break;
                default:
                    print("error default")
                }
                break;
                
            case 5:
                // use 6 bits from 2nd byte and 4 bits from 3rd byte to lookup emoji
                output.append(emojis[(b1 & 0x3f)<<4 | b2>>4])
                // use 4 bits from 3rd byte and 6 bits from 4th byte to lookup emoji
                output.append(emojis[(b2 & 0x0f)<<6 | b3>>2])
                //user 2 bits from 4th byte and 8 bits from 5th byte to lookup emoji
                output.append(emojis[(b3 & 0x03)<<8 | b4]);
                break;
            default:
                print("error default clause")
            }
            numRead = dataStream.read(&buffer, maxLength: numBytesPerObject)
        }
        return String(output)
    }
}

public class EcojiDecoder {
    public init() {}
    
    private func readChar() {
        
    }
    
    public func decode(string input: String) throws -> Data {
        
        for char in input {
            print(char)
        }
        
        return Data()
    }

}
