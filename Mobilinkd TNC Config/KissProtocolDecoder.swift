//
//  KissProtocolDecoder.swift
//  Basic Chat
//
//  Created by Rob Riggs on 12/30/18.
//  Copyright © 2018 Mobilinkd LLC. All rights reserved.
//

import Foundation

enum KissPacketError : Error {
    case invalidPacketData
    case invalidPacketLength
}

class KissPacket
{

    enum PacketType : UInt8 {
        case Data = 0
        case TxDelay = 1
        case Persistance = 2
        case SlotTime = 3
        case TxTail = 4
        case Duplex = 5
        case Hardware = 6
        case Escape = 15    // 0x0F
    }
    
    var port : UInt8
    var packetType : PacketType
    var data : Data
    var count : Int
    
    init(incoming : Data) {
        if incoming.count < 1 {
            throw KissPacketError.invalidPacketLength
        }

        let typeByte = incoming[0]
        port = (typeByte & 0xF0) >> 4
        packetType = PacketType(rawValue: (typeByte & 0x0F))
        data = incoming[1...]
        count = data.count
    }

    func asByte() -> UInt8 {
    }
}
