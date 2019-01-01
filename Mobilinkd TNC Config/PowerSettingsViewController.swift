//
//  PowerSettingsViewController.swift
//  Mobilinkd TNC Config
//
//  Created by Rob Riggs on 12/29/18.
//  Copyright © 2018 Mobilinkd LLC. All rights reserved.
//

import UIKit

class PowerSettingsViewController: UIViewController {

    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var batteryLevelBar: UIProgressView!
    @IBOutlet weak var usbPowerOnSwitch: UISwitch!
    @IBOutlet weak var usbPowerOffSwitch: UISwitch!
    
    @IBAction func usbPowerOnSwitchChanged(_ sender: UISwitch) {
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetUsbPowerOn(value: sender.isOn))
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
    }
    
    @IBAction func usbPowerOffSwitchChanged(_ sender: UISwitch) {
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetUsbPowerOff(value: sender.isOn))
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
    }
    
    var batteryLevel : UInt16?
    var usbPowerOn : Bool?
    var usbPowerOff : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if batteryLevel != nil {
            updateBatteryLevel(level: batteryLevel!)
            batteryLevelBar.trackTintColor = UIColor.lightGray
            batteryLevelBar.transform = batteryLevelBar.transform.scaledBy(x: 1.0, y: 10.0)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.batteryLevelNotification),
            name: TncConfigMenuViewController.tncBatteryLevelNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.usbPowerOnNotification),
            name: TncConfigMenuViewController.tncUsbPowerOnNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.usbPowerOffNotification),
            name: TncConfigMenuViewController.tncUsbPowerOffNotification,
            object: nil)

        print("all power notification subscribed")
        
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.GetBatteryLevel())
        
        print("sent GetBatteryLevel to TNC")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(
            self,
            name: TncConfigMenuViewController.tncBatteryLevelNotification,
            object: nil)
        print("tncBatteryLevelNotification unsubscribed")
        NotificationCenter.default.removeObserver(
            self,
            name: TncConfigMenuViewController.tncUsbPowerOnNotification,
            object: nil)
        print("tncUsbPowerOnNotification unsubscribed")
        NotificationCenter.default.removeObserver(
            self,
            name: TncConfigMenuViewController.tncUsbPowerOffNotification,
            object: nil)
        print("tncUsbPowerOffNotification unsubscribed")
    }

    func updateBatteryLevel(level: UInt16) {
        print("setting battery level: \((String(format: "%04dmV", level)))")
        batteryLevel = level
        batteryLevelLabel.text = String(format: "%04dmV", level)
        batteryLevelBar.progress = max(0.1, min(1.0, (Float(level) - 3300.0) / 900.0))
        
        if batteryLevelBar.progress < 0.15 {
            batteryLevelBar.progressTintColor = UIColor.red
        } else if batteryLevelBar.progress < 0.33 {
            batteryLevelBar.progressTintColor = UIColor.orange
        } else {
            batteryLevelBar.progressTintColor = UIColor.green
        }
    }
    
    @objc public func batteryLevelNotification(notification: NSNotification)
    {
        print("batteryLevelNotification")
        
        if let packet = notification.object as? KissPacketDecoder {
            if let value = packet.asUInt16() {
                updateBatteryLevel(level: value)
            }
        }
    }
    
    @objc public func usbPowerOnNotification(notification: NSNotification)
    {
        print("usbPowerOnNotification")
        
        if let packet = notification.object as? KissPacketDecoder {
            if let value = packet.asUInt8() {
                usbPowerOnSwitch.isOn = value == 1
            }
        }
    }
    
    @objc public func usbPowerOffNotification(notification: NSNotification)
    {
        print("usbPowerOffNotification")
        
        if let packet = notification.object as? KissPacketDecoder {
            if let value = packet.asUInt8() {
                usbPowerOffSwitch.isOn = value == 1
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
