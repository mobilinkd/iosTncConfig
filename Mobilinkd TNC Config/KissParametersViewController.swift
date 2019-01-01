//
//  KissParametersViewController.swift
//  Mobilinkd TNC Config
//
//  Created by Rob Riggs on 12/29/18.
//  Copyright © 2018 Mobilinkd LLC. All rights reserved.
//

import UIKit

class KissParametersViewController: UIViewController {

    @IBOutlet weak var txDelayTextField: UITextField!
    @IBOutlet weak var txDelayStepper: UIStepper!
    @IBOutlet weak var persistenceTextField: UITextField!
    @IBOutlet weak var persistenceStepper: UIStepper!
    @IBOutlet weak var timeSlotTextField: UITextField!
    @IBOutlet weak var timeSlotStepper: UIStepper!
    @IBOutlet weak var duplexSwitch: UISwitch!

    @IBAction func txDelayEdited(_ sender: UITextField) {
        if let value = UInt8(sender.text!) {
            if value >= 0 && value <= 255 {
                txDelay = value
                txDelayStepper.value = Double(value)
                NotificationCenter.default.post(
                    name: BLECentralViewController.bleDataSendNotification,
                    object: KissPacketEncoder.SetTxDelay(value: txDelay!))
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncModifiedNotification,
                    object: nil)
            } else {
                if txDelay != nil {
                    sender.text = txDelay!.description
                } else {
                    sender.text = ""
                }
            }
        }
    }
    
    @IBAction func txDelayChanged(_ sender: UIStepper) {
        self.txDelayTextField.text = Int(sender.value).description
    }
    
    @IBAction func txDelayChangeComplete(_ sender: UIStepper) {
    }
    
    @IBAction func persistenceEdited(_ sender: UITextField) {
    }
    
    @IBAction func persistenceChanged(_ sender: UIStepper) {
        self.persistenceTextField.text = Int(sender.value).description
    }
    
    @IBAction func persistenceChangeComplete(_ sender: UIStepper) {
    }
    
    @IBAction func timeSlotEdited(_ sender: UITextField) {
    }
    
    @IBAction func timeSlotChanged(_ sender: UIStepper) {
        self.timeSlotTextField.text = Int(sender.value).description
    }
    
    @IBAction func timeSlotChangeComplete(_ sender: UIStepper) {
        timeSlot = UInt8(sender.value)
    }
    
    @IBAction func duplexChanged(_ sender: UISwitch) {
        duplex = sender.isOn
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetDuplex(value: sender.isOn))
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if txDelay != nil {
            txDelayTextField.text = txDelay!.description
            txDelayStepper.value = Double(txDelay!)
        }
        
        if persistence != nil {
            persistenceTextField.text = persistence!.description
            persistenceStepper.value = Double(persistence!)
        }
        
        if timeSlot != nil {
            timeSlotTextField.text = timeSlot!.description
            timeSlotStepper.value = Double(timeSlot!)
        }
        
        if duplex != nil {
            duplexSwitch.isOn = duplex!
        }
        
        txDelayTextField.clearsOnBeginEditing = true
        persistenceTextField.clearsOnBeginEditing = true
        timeSlotTextField.clearsOnBeginEditing = true
    }
}
