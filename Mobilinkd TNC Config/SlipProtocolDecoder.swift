//
//  KissProtocolDecoder.swift
//  Mobilinkd TNC Config
//
//  Created by Rob Riggs on 12/30/18.
//  Copyright © 2018 Mobilinkd LLC. All rights reserved.
//

import Foundation

class SlipProtocolDecoder
{
    let FEND = 0xC0
    let FESC = 0xDB
    let TFEND = 0xDC
    let TFESC = 0xDD

    enum State {
        case START
        case DECODING
        case ESCAPING
    }
    
    var state : State
    var data : Data
    
    init() {
        data = Data()
        state = State.START
    }
    
    /**
     * SLIP decoding state maching.
     *
     * @note Because the data requirements of BLE transfer is a bit
     * stricter, it is required that a KISS frame start with a single
     * FEND byte and end with a single FEND byte. This simplifies the
     * state machine greatly over the default where it is permissible
     * to separate two packets with a single FEND.
     *
     * This function returns an array of Data buffers.  The array may be
     * empty if the incoming data was an incomplete array.  Otherwise it
     * may contain one or more decoded packets.
     */
    func decode(incoming : Data) -> [Data] {
        var result = [Data]()
        for byte : UInt8 in incoming {
            switch state {
            case .START:
                if byte == FEND {
                    state = .DECODING
                }
                break
            case .DECODING:
                if byte == FESC {
                    state = .ESCAPING
                } else if byte == FEND {
                    // Note: we may encounter two FEND back to back if an
                    // escape sequence error occurred.  We will get the STOP
                    // FESC which puts us in DECODING, then the START FESC
                    // arrives.  We therefore ignore consecutive FESC bytes.
                    if data.count > 0 {
                        result.append(data)
                        data = Data()
                        state = .START
                    }
                } else {
                    data.append(byte)
                }
                break
            case .ESCAPING:
                if byte == TFEND {
                    data.append(UInt8(FEND))
                    state = .DECODING
                } else if byte == TFESC {
                    data.append(UInt8(FESC))
                    state = .DECODING
                } else {
                    print("Error decoding KISS packet -- bad escape sequence")
                    data = Data()
                    state = .START
                }
            }
        }
        return result
    }
}
