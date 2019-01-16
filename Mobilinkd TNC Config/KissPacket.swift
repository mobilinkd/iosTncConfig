//
//  KissProtocolDecoder.swift
//  Mobilinkd TNC Config
//
//  Created by Rob Riggs on 12/30/18.
//  Copyright © 2018 Mobilinkd LLC. All rights reserved.
//

import Foundation

enum KissPacketError : Error {
    case invalidPacketData
    case invalidPacketLength
}

class KissPacketDecoder
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
    
    enum HardwareType : UInt8 {
        case INPUT_LEVEL = 4
        case BATTERY_LEVEL = 6
        case TX_VOLUME = 12
        case TX_TWIST = 27            // API 2.0
        case INPUT_GAIN = 13          // API 2.0
        case SQUELCH_LEVEL = 14
        case VERBOSITY = 17
        case INPUT_TWIST = 25         // API 2.0
        
        case TX_DELAY = 33
        case PERSISTENCE = 34
        case SLOT_TIME = 35
        case TX_TAIL = 36
        case DUPLEX = 37
        
        case FIRMWARE_VERSION = 40
        case HARDWARE_VERSION = 41
        case SERIAL_NUMBER = 47       // API 2.0
        case GET_MAC_ADDRESS = 48     // API 2.0
        case DATE_TIME = 49           // API 2.0
        case CONNECTION_TRACKING = 70
        case USB_POWER_ON = 74
        case USB_POWER_OFF = 76
        
        case PTT_CHANNEL = 80

        case MIN_OUTPUT_TWIST = 119   // API 2.0
        case MAX_OUTPUT_TWIST = 120   // API 2.0
        case MIN_INPUT_TWIST = 121    // API 2.0
        case MAX_INPUT_TWIST = 122    // API 2.0
        case API_VERSION = 123        // API 2.0
        case MIN_INPUT_GAIN = 124     // API 2.0
        case MAX_INPUT_GAIN = 125     // API 2.0
        case CAPABILITIES = 126
    }
    
    enum Capabilities : UInt16 {
        case CAP_EEPROM_SAVE = 0x0002
        case CAP_ADJUST_INPUT = 0x0004
        case CAP_DFU_FIRMWARE = 0x0008
    }
    
    var port : UInt8
    var packetType : PacketType
    var hardwareType : HardwareType?
    var capabilities : Capabilities?
    var data : Data
    var count : Int
    
    init(incoming : Data) throws {
        if incoming.count < 1 {
            throw KissPacketError.invalidPacketLength
        }

        let typeByte = incoming[0]
        port = (typeByte & 0xF0) >> 4
        let pType = PacketType(rawValue: (typeByte & 0x0F))!
        if incoming.count > 2 && pType == .Hardware {
            hardwareType = HardwareType(rawValue: incoming[1])
            data = Data(incoming[2...])
        } else {
            data = Data(incoming[1...])
        }
        
        packetType = pType
        count = data.count
    }

    func asUInt8() -> UInt8? {
        return data[0]
    }
    
    func asUInt16() -> UInt16? {
        // Big endian...
        if data.count > 1 {
            return UInt16(UInt16(data[0]) * 256) + UInt16(data[1])
        }
        return nil
    }
    
    func asString() -> String? {
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func isHardwareType() -> Bool {
        return hardwareType != nil
    }
    
    func getHardwareType() -> HardwareType?
    {
        return hardwareType
    }
    
    func isCapabilities() -> Bool {
        return hardwareType == .CAPABILITIES
    }
    
    func getCapabilities() -> Capabilities? {
        if hardwareType == .CAPABILITIES {
            if let cap = self.asUInt16() {
                return Capabilities(rawValue: cap)
            }
        }
        return nil
    }
}

class KissPacketEncoder {
    
    enum PacketType : UInt8 {
        case Data = 0
        case TxDelay = 1
        case Persistence = 2
        case SlotTime = 3
        case TxTail = 4
        case Duplex = 5
        case Hardware = 6
    }
    
    enum HardwareType : UInt8 {
        case SET_OUTPUT_GAIN = 1
        case SET_INPUT_GAIN = 2
        case POLL_INPUT_LEVEL = 4
        case STREAM_INPUT_LEVEL = 5
        case BATTERY_LEVEL = 6
        case SEND_MARK = 7
        case SEND_SPACE = 8
        case SEND_BOTH = 9
        case STOP_TX = 10
        case RESET = 11             // API 2.0 -- restart demodulator
        case TX_VOLUME = 12
        case INPUT_GAIN = 13        // API 2.0
        case SQUELCH_LEVEL = 14
        case VERBOSITY = 17
        case SET_INPUT_TWIST = 24   // API 2.0
        case SET_OUTPUT_TWIST = 26  // API 2.0
        case TX_DELAY = 33
        case PERSISTENCE = 34
        case SLOT_TIME = 35
        case TX_TAIL = 36
        case DUPLEX = 37
        
        case FIRMWARE_VERSION = 40
        case HARDWARE_VERSION = 41
        case SAVE_EEPROM_SETTINGS = 42
        case ADJUST_INPUT_LEVELS = 43       // API 2.0
        case SET_DATE_TIME = 50             // API 2.0
        case SET_USB_POWER_ON = 73
        case SET_USB_POWER_OFF = 75
        
        case SET_PTT_CHANNEL = 79
        
        case MIN_INPUT_TWIST = 121    // API 2.0
        case MAX_INPUT_TWIST = 122    // API 2.0
        case API_VERSION = 123        // API 2.0
        case MIN_INPUT_GAIN = 124     // API 2.0
        case MAX_INPUT_GAIN = 125     // API 2.0
        case CAPABILITIES = 126
        case READ_ALL_VALUES = 127
    }

    let packetType : PacketType
    let hardwareType : HardwareType?
    let data : Data
    
    init(packetType: PacketType, data: UInt8) {
        self.packetType = packetType
        self.hardwareType = nil
        self.data = Data([data])
    }
    
    init(hardwareType: HardwareType?) {
        self.packetType = .Hardware
        self.hardwareType = hardwareType
        self.data = Data()
    }
    
    init(hardwareType: HardwareType?, data: Data) {
        self.packetType = .Hardware
        self.hardwareType = hardwareType
        self.data = data
    }
    
    init(hardwareType: HardwareType?, data: UInt8) {
        self.packetType = .Hardware
        self.hardwareType = hardwareType
        self.data = Data([data])
    }
    
    init(hardwareType: HardwareType?, data: UInt16) {
        self.packetType = .Hardware
        self.hardwareType = hardwareType
        self.data = Data([UInt8(data >> 8),UInt8(data & 0xFF)])
    }

    func encode() -> Data {
        var result = Data()
        result.append(packetType.rawValue)
        if packetType == .Hardware {
            result.append(hardwareType!.rawValue)
        }
        result += data
        return result
    }

    static func ReadAllValues() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .READ_ALL_VALUES).encode())
    }

    static func SaveEepromSettings() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SAVE_EEPROM_SETTINGS).encode())
    }
    
    static func GetBatteryLevel() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .BATTERY_LEVEL).encode())
    }
    
    static func SetUsbPowerOn(value: Bool) -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SET_USB_POWER_ON, data: UInt8(value ? 1 : 0)).encode())
    }
    
    static func SetUsbPowerOff(value: Bool) -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SET_USB_POWER_OFF, data: UInt8(value ? 1 : 0)).encode())
    }
    
    static func StreamInputLevel() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .STREAM_INPUT_LEVEL).encode())
    }
    
    static func PollInputLevel() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .POLL_INPUT_LEVEL).encode())
    }
    
    static func SetAudioInputGain(value: Int16) -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SET_INPUT_GAIN, data: UInt16(bitPattern:value)).encode())
    }
    
    static func SetAudioInputTwist(value: Int8) -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SET_INPUT_TWIST, data: UInt8(bitPattern: value)).encode())
    }
    
    static func AdjustInputLevels() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .ADJUST_INPUT_LEVELS).encode())
    }
    
    static func SetPttSimplex() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SET_PTT_CHANNEL, data: UInt8(0)).encode())
    }
    
    static func SetPttMultiplex() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SET_PTT_CHANNEL, data: UInt8(1)).encode())
    }

    static func TransmitMark() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SEND_MARK).encode())
    }
    
    static func TransmitSpace() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SEND_SPACE).encode())
    }
    
    static func TransmitBoth() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SEND_BOTH).encode())
    }
    
    static func StopTransmit() -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .STOP_TX).encode())
    }
    
    static func SetAudioOutputGain(value: Int16) -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SET_OUTPUT_GAIN, data: UInt16(bitPattern:value)).encode())
    }
    
    static func SetAudioOutputTwist(value: Int8) -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SET_OUTPUT_TWIST, data: UInt8(bitPattern: value)).encode())
    }
    
    /*
     * The requirement for the TNC (really the STM32 RTC inside the TNC) is
     * that the datetime value is a binary-coded decimal representation of the
     * date, day of week, and time.  Items of note:
     *
     * - Year is 2-digits (modulus 100)
     * - Month is indexed at 1
     * - Day is indexed at 1
     * - Weekday is indexed at 1 = Monday (1..7) per ISO-8601
     *
     * For iOS calendar, these are the key differences:
     *
     * - Year is a full 4 digits
     * - Weekday is indexed at 1 = Sunday (some made up standard, I guess)
     *
     * Here we have to conver
     */
    private static func make_time() -> Data {
        
        func bcd(_ value: Int) -> UInt8 {
              return UInt8(((value / 10) * 16) + (value % 10));
        }
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: Date())
        let year = components.year! % 100
        let month = components.month!
        let day = components.day!
        var weekday = components.weekday! - 1
        weekday = weekday < 1 ? 7 : weekday   // Monday is 1 in the ISO world...
        let hour = components.hour!
        let minute = components.minute!
        let seconds = components.second!
        
        return Data([bcd(year), bcd(month), bcd(day), UInt8(weekday), bcd(hour), bcd(minute), bcd(seconds)])
    }
    
    static func SetDateTime() -> Data {
        // BCD-encoded YYMMDDWDHHMMSS - 7 bytes. (WD = weekday)
        let time = make_time()
        print("setting time to: \((time.hexEncodedString()))")
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(hardwareType: .SET_DATE_TIME, data: time).encode())
    }

    static func SetTxDelay(value: UInt8) -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(packetType: .TxDelay, data: value).encode())
    }

    static func SetPersistence(value: UInt8) -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(packetType: .Persistence, data: value).encode())
    }
    
    static func SetSlotTime(value: UInt8) -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(packetType: .SlotTime, data: value).encode())
    }
    
    static func SetDuplex(value: Bool) -> Data {
        return SlipProtocolEncoder.encode(
            value: KissPacketEncoder(packetType: .Duplex, data: UInt8(value ? 1 : 0)).encode())
    }
}

