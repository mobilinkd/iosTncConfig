//
//  SlipProtocolEncoder.swift
//  Mobilinkd TNC Config
//
//  Created by Rob Riggs on 12/30/18.
//  Copyright © 2018 Mobilinkd LLC. All rights reserved.
//

import Foundation

class SlipProtocolEncoder {

    static let FEND = UInt8(0xC0)
    static let FESC = UInt8(0xDB)
    static let TFEND = UInt8(0xDC)
    static let TFESC = UInt8(0xDD)


    static func encode(value: Data) -> Data {
        var result = Data([FEND])

        for byte : UInt8 in value {
            if byte == FEND {
                result.append(FESC)
                result.append(TFEND)
            } else if byte == FESC {
                result.append(FESC)
                result.append(TFESC)
            } else {
                result.append(byte)
            }
        }
        result.append(FEND)
        
        return result
    }
}
