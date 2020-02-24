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
        let value = UInt8(sender.text!)
        if value != nil {
            txDelay = value!
            self.txDelayStepper.value = Double(value!)
            NotificationCenter.default.post(
                name: BLECentralViewController.bleDataSendNotification,
                object: KissPacketEncoder.SetTxDelay(value: value!))
            NotificationCenter.default.post(
                name: TncConfigMenuViewController.tncModifiedNotification,
                object: nil)
        } else {
            sender.text = self.txDelayStepper.value.description
        }
    }
    
    @IBAction func txDelayChanged(_ sender: UIStepper) {
        self.txDelayTextField.text = Int(sender.value).description
    }
    
    @IBAction func txDelayChangeComplete(_ sender: UIStepper) {
        txDelay = UInt8(sender.value)
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetTxDelay(value: UInt8(sender.value)))
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
    }
    
    @IBAction func persistenceEdited(_ sender: UITextField) {
        let value = UInt8(sender.text!)
        if value != nil {
            persistence = value!
            self.persistenceStepper.value = Double(value!)
            NotificationCenter.default.post(
                name: BLECentralViewController.bleDataSendNotification,
                object: KissPacketEncoder.SetPersistence(value: value!))
            NotificationCenter.default.post(
                name: TncConfigMenuViewController.tncModifiedNotification,
                object: nil)
        } else {
            sender.text = self.persistenceStepper.value.description
        }
    }
    
    @IBAction func persistenceChanged(_ sender: UIStepper) {
        self.persistenceTextField.text = Int(sender.value).description
    }
    
    @IBAction func persistenceChangeComplete(_ sender: UIStepper) {
        persistence = UInt8(sender.value)
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetPersistence(value: UInt8(sender.value)))
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
    }
    
    @IBAction func timeSlotEdited(_ sender: UITextField) {
        let value = UInt8(sender.text!)
        if value != nil {
            timeSlot = value!
            self.timeSlotStepper.value = Double(value!)
            NotificationCenter.default.post(
                name: BLECentralViewController.bleDataSendNotification,
                object: KissPacketEncoder.SetTxDelay(value: value!))
            NotificationCenter.default.post(
                name: TncConfigMenuViewController.tncModifiedNotification,
                object: nil)
        } else {
            sender.text = self.timeSlotStepper.value.description
        }
    }
    
    @IBAction func timeSlotChanged(_ sender: UIStepper) {
        self.timeSlotTextField.text = Int(sender.value).description
    }
    
    @IBAction func timeSlotChangeComplete(_ sender: UIStepper) {
        timeSlot = UInt8(sender.value)
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetSlotTime(value: UInt8(sender.value)))
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
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
    
    override func viewDidAppear(_ animated: Bool) {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didLoseConnection),
            name: BLECentralViewController.bleDisconnectNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willResignActiveNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: BLECentralViewController.bleDisconnectNotification,
            object: nil)
    }

    @objc func willResignActive(notification: NSNotification)
    {
        print("KissParametersViewController.willResignActive")
        disconnectBle()
    }
    
    @objc func didBecomeActive(notification: NSNotification)
    {
        if blePeripheral == nil {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    @objc func didLoseConnection(notification: NSNotification)
    {
        let alert = UIAlertController(
            title: "LostBLETitle".localized,
            message: "LostBLEMessage".localized,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.navigationController?.popToRootViewController(animated: false)
        }))
        self.present(alert, animated: true)
    }
}
