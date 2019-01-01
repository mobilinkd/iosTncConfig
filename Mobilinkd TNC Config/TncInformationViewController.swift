//
//  TncInformationViewController.swift
//  Mobilinkd TNC Config
//
//  Created by Rob Riggs on 12/30/18.
//  Copyright © 2018 Mobilinkd LLC. All rights reserved.
//

import UIKit

class TncInformationViewController: UIViewController {

    var mainViewController : BLECentralViewController?
    
    //UI
    @IBOutlet weak var hardwareVersionLabel: UILabel!
    @IBOutlet weak var firmwareVersionLabel: UILabel!
    @IBOutlet weak var macAddressLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!

    var hardwareVersion : String?
    var firmwareVersion : String?
    var macAddress : String?
    var serialNumber : String?
    var dateTime : String?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        hardwareVersionLabel.text = hardwareVersion
        firmwareVersionLabel.text = firmwareVersion
        macAddressLabel.text = macAddress
        serialNumberLabel.text = serialNumber
        dateTimeLabel.text = dateTime
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.dateTimeNotification),
            name: TncConfigMenuViewController.tncDateTimeNotification,
            object: nil)
        
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetDateTime())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: TncConfigMenuViewController.tncDateTimeNotification,
            object: nil)
    }
    
    @objc public func dateTimeNotification(notification: NSNotification)
    {
        print("tncDateTimeNotification")
        
        if let packet = notification.object as? KissPacketDecoder {
            updateDateTime(packet.data)
        }
        dateTimeLabel.text = dateTime
    }
    
    // See implementation notes from KissPacketEncoder.make_time()
    func updateDateTime(_ value : Data) {
        func from_bcd(_ value : UInt8) -> Int {
            return Int((value / 16) * 10) + Int(value & 15)
        }
        
        if value.count < 7 {
            print("Bad time value received")
            return
        }
        
        var date = DateComponents()
        date.year = from_bcd(value[0]) + 2000
        date.month = from_bcd(value[1])
        date.day = from_bcd(value[2])
        date.weekday = Int(value[3]) + 1 > 7 ? 1 : Int(value[3]) + 1
        date.hour = from_bcd(value[4])
        date.minute = from_bcd(value[5])
        date.second = from_bcd(value[6])
        date.timeZone = TimeZone(identifier: "UTC")
        
        dateTime = String(format: "%04d-%02d-%02d %02d:%02d:%02d",
            date.year!, date.month!, date.day!,
            date.hour!, date.minute!, date.second!)
    }
}
