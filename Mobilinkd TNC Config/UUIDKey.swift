//
//  UUIDKey.swift
//  Mobilinkd TNC Config
//
//  Created by Trevor Beaton on 12/3/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//

import CoreBluetooth

let kBLEService_UUID = "00000001-ba2a-46c9-ae49-01b0961f68bb"
let kBLE_Characteristic_uuid_Tx = "00000002-ba2a-46c9-ae49-01b0961f68bb"
let kBLE_Characteristic_uuid_Rx = "00000003-ba2a-46c9-ae49-01b0961f68bb"
let MaxCharacters = 20

let BLEService_UUID = CBUUID(string: kBLEService_UUID)
let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)
