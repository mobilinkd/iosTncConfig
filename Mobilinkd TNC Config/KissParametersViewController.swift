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
            title: "Lost BLE Connection",
            message: "The connection to the TNC has been lost.  You will need to re-establish the connection.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.navigationController?.popToRootViewController(animated: false)
        }))
        self.present(alert, animated: true)
    }
}
