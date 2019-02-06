//
//  AudioOutputViewController.swift
//  Mobilinkd TNC Config
//
//  Created by Rob Riggs on 12/29/18.
//  Copyright © 2018 Mobilinkd LLC. All rights reserved.
//

import UIKit

class AudioOutputViewController: UIViewController {

    enum PttStyle : UInt8 {
        case Simplex = 0
        case Multiplex = 1
    }

    enum Tone : UInt8 {
        case MARK = 1
        case SPACE = 2
        case BOTH = 3
    }

    var pttStyle: PttStyle?
    var audioOutputGain : Int16?
    var audioOutputGainMinimum = Int16(0);
    var audioOutputGainMaximum = Int16(255);
    var audioOutputTwist : Int8?
    var audioOutputTwistMinimum : Int8?
    var audioOutputTwistMaximum : Int8?
    
    var tone = Tone.MARK

    var lastOutputGainUpdateTime = CACurrentMediaTime()
    var lastOutputTwistUpdateTime = CACurrentMediaTime()

    @IBOutlet weak var pttStyleSwitch: UISegmentedControl!
    
    @IBOutlet weak var audioOutputGainSlider: UISlider!

    @IBOutlet weak var audioOutputGainMinimumLabel: UILabel!
    
    @IBOutlet weak var audioOutputGainLabel: UILabel!
    
    @IBOutlet weak var audioOutputGainMaximumLabel: UILabel!
    
    @IBOutlet weak var audioOutputTwistSlider: UISlider!
    
    @IBOutlet weak var audioOutputTwistMinimimLabel: UILabel!
    
    @IBOutlet weak var audioOutputTwistLabel: UILabel!
    
    @IBOutlet weak var audioOutputTwistMaximumLabel: UILabel!
    
    @IBOutlet weak var transmitToneSwitch: UISegmentedControl!
    
    @IBOutlet weak var transmitButton: UIButton!
    
    @IBAction func pttStyleChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            NotificationCenter.default.post(
                name: BLECentralViewController.bleDataSendNotification,
                object: KissPacketEncoder.SetPttSimplex())
        } else if sender.selectedSegmentIndex == 1 {
            NotificationCenter.default.post(
                name: BLECentralViewController.bleDataSendNotification,
                object: KissPacketEncoder.SetPttMultiplex())
        } else {
            print("BUG: Invalid PTT Style selection occurred")
        }
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
    }
    
    @IBAction func audioOutputGainChanged(_ sender: UISlider) {
        updateOutputGain(value: Int16(audioOutputGainSlider.value))
        if CACurrentMediaTime() - lastOutputGainUpdateTime > 0.1 {
            sendData(KissPacketEncoder.SetAudioOutputGain(value: audioOutputGain!))
            lastOutputGainUpdateTime = CACurrentMediaTime()
        }
    }
    
    func updateOutputGain(value : Int16) {
        audioOutputGain = value
        audioOutputGainSlider.value = Float(value)
        audioOutputGainLabel.text = String(format: "%d", value)
    }

    @IBAction func audioOutputGainChangeComplete(_ sender: UISlider) {
        updateOutputGain(value : Int16(audioOutputGainSlider.value))
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetAudioOutputGain(value: audioOutputGain!))
        lastOutputGainUpdateTime = CACurrentMediaTime()
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
    }
    
    @IBAction func audioOutputTwistChanged(_ sender: Any) {
        updateOutputTwist(value: Int8(audioOutputTwistSlider.value))
        if CACurrentMediaTime() - lastOutputTwistUpdateTime > 0.1 {
            NotificationCenter.default.post(
                name: BLECentralViewController.bleDataSendNotification,
                object: KissPacketEncoder.SetAudioOutputTwist(value: audioOutputTwist!))
            lastOutputTwistUpdateTime = CACurrentMediaTime()
        }
    }
    
    func updateOutputTwist(value : Int8) {
        audioOutputTwist = value
        audioOutputTwistSlider.value = Float(value)
        audioOutputTwistLabel.text = String(format: "%d", value)
    }

    @IBAction func audioOutputTwistChangeComplete(_ sender: Any) {
        updateOutputTwist(value : Int8(audioOutputTwistSlider.value))
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetAudioOutputTwist(value: audioOutputTwist!))
        lastOutputTwistUpdateTime = CACurrentMediaTime()
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
    }
    
    @IBAction func transmitToneChanged(_ sender: UISegmentedControl) {
        if transmitButton.isSelected {
            transmitTone()
        }
    }
    
    @IBAction func transmitChanged(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            stopTransmit()
        } else {
            sender.isSelected = true
            transmitTone()
        }
    }
    
    func transmitTone() {
        if transmitToneSwitch.selectedSegmentIndex == 0 {
            sendDataNow(KissPacketEncoder.TransmitMark())
        } else if transmitToneSwitch.selectedSegmentIndex == 1 {
            sendDataNow(KissPacketEncoder.TransmitSpace())
        } else if transmitToneSwitch.selectedSegmentIndex == 2 {
            sendDataNow(KissPacketEncoder.TransmitBoth())
        }
        audioOutputGainSlider.isEnabled = true
        audioOutputTwistSlider.isEnabled = true
    }
    
    func stopTransmit() {
        sendDataNow(KissPacketEncoder.StopTransmit())
        sendData(KissPacketEncoder.PollInputLevel())
        audioOutputGainSlider.isEnabled = false
        audioOutputTwistSlider.isEnabled = false
    }
    
    func setAudioOutputGain(value: Int16) {
        audioOutputGainLabel.text = String(format: "%d", value)
        audioOutputGainSlider.value = Float(value)
    }
    
    func setPttStyel(value : UInt8) {
        pttStyle = PttStyle(rawValue: value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioOutputGainSlider.isEnabled = false
        audioOutputTwistSlider.isEnabled = false
        if audioOutputGain != nil {
            updateOutputGain(value: audioOutputGain!)
        }
        if audioOutputTwist != nil {
            updateOutputTwist(value: audioOutputTwist!)
        }
        if pttStyle != nil {
            pttStyleSwitch.selectedSegmentIndex = Int(pttStyle!.rawValue)
        }
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didLoseConnection),
            name: BLECentralViewController.bleDisconnectNotification,
            object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Stop streaming input volume levels
        transmitButton.isSelected = false
        stopTransmit()
        
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
        print("AudioOutputViewController.willResignActive")
        // Stop streaming input volume levels
        stopTransmit()
        transmitButton.isSelected = false
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
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true)
    }
}
