//
//  AudioInputViewController.swift
//  Mobilinkd TNC Config
//
//  Created by Rob Riggs on 12/29/18.
//  Copyright © 2018 Mobilinkd LLC. All rights reserved.
//

import UIKit
import CoreBluetooth

class AudioInputViewController: UIViewController {

    @IBOutlet weak var audioInputLevelBar: UIProgressView!
    @IBOutlet weak var audioInputGainSlider: UISlider!
    @IBOutlet weak var audioInputTwistSlider: UISlider!
    
    @IBOutlet weak var audioInputMaximumGainLabel: UILabel!

    @IBOutlet weak var audioInputGainLabel: UILabel!
    @IBOutlet weak var audioInputMinimumGainLabel: UILabel!
    
    @IBOutlet weak var audioInputMinimumTwistLabel: UILabel!
    @IBOutlet weak var audioInputTwistLabel: UILabel!
    @IBOutlet weak var audioInputMaximumTwistLabel: UILabel!
    
    @IBOutlet weak var autoAdjustInputLevelsButton: UIButton!
    
    @IBAction func audioInputLevelChanged(_ sender: UISlider) {
        audioInputGain = Int16(audioInputGainSlider.value)
        audioInputGainSlider.value = Float(audioInputGain!)
        audioInputGainLabel.text = String(format: "%d", audioInputGain!)
        if CACurrentMediaTime() - lastInputGainUpdateTime > 0.1 {
            NotificationCenter.default.post(
                name: BLECentralViewController.bleDataSendNotification,
                object: KissPacketEncoder.SetAudioInputGain(value: audioInputGain!))
            lastInputGainUpdateTime = CACurrentMediaTime()
            NotificationCenter.default.post(
                name: TncConfigMenuViewController.tncModifiedNotification,
                object: nil)
        }
    }
    
    func updateInputGain(value: Int16) {
        audioInputGain = value
        audioInputGainSlider.value = Float(value)
        audioInputGainLabel.text = String(format: "%d", value)
    }
    
    @IBAction func audioInputLevelChangeComplete(_ sender: UISlider) {
        updateInputGain(value: Int16(audioInputGainSlider.value))
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetAudioInputGain(value: audioInputGain!))
        lastInputGainUpdateTime = CACurrentMediaTime()
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
    }
    
    @IBAction func audioInputTwistChanged(_ sender: UISlider) {
        updateInputTwist(value: Int8(audioInputTwistSlider.value))
        if CACurrentMediaTime() - lastInputTwistUpdateTime > 0.1 {
            NotificationCenter.default.post(
                name: BLECentralViewController.bleDataSendNotification,
                object: KissPacketEncoder.SetAudioInputTwist(value: audioInputTwist!))
            lastInputTwistUpdateTime = CACurrentMediaTime()
            NotificationCenter.default.post(
                name: TncConfigMenuViewController.tncModifiedNotification,
                object: nil)
        }
    }
    
    func updateInputTwist(value : Int8) {
        audioInputTwist = value
        audioInputTwistSlider.value = Float(value)
        audioInputTwistLabel.text = String(format: "%ddB", value)
    }
    
    @IBAction func audoInputTwistChangeComplete(_ sender: UISlider) {
        updateInputTwist(value : Int8(audioInputTwistSlider.value))
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SetAudioInputTwist(value: audioInputTwist!))
        lastInputTwistUpdateTime = CACurrentMediaTime()
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
    }
    
    @IBAction func autoAdjustButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.AdjustInputLevels())
        NotificationCenter.default.post(
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
    }
    
    var audioInputGainMinimum : Int16?
    var audioInputGainMaximum : Int16?
    var audioInputTwistMinimum : Int8?
    var audioInputTwistMaximum : Int8?
    
    var audioInputGain : Int16?
    var audioInputTwist : Int8?
    
    var lastInputGainUpdateTime = CACurrentMediaTime()
    var lastInputTwistUpdateTime = CACurrentMediaTime()
    
    let log2 = log(Float(2.0))
    
    // SlipProtocolDecoder maintains state to handle packets that are split
    // across multiple MTU blocks.
    var slipDecoder = SlipProtocolDecoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AudioInputViewController.viewDidLoad")

        audioInputLevelBar.trackTintColor = UIColor.lightGray
        audioInputLevelBar.transform = audioInputLevelBar.transform.scaledBy(x: 1.0, y: 10.0)

        if audioInputGainMinimum != nil {
            audioInputMinimumGainLabel.text = String(format: "%d", audioInputGainMinimum!)
            audioInputGainSlider.minimumValue = Float(audioInputGainMinimum!)
        }
        if audioInputGainMaximum != nil {
            audioInputMaximumGainLabel.text = String(format: "%d", audioInputGainMaximum!)
            audioInputGainSlider.maximumValue = Float(audioInputGainMaximum!)
        }
        if audioInputTwistMinimum != nil {
            audioInputMinimumTwistLabel.text = String(format: "%d", audioInputTwistMinimum!)
            audioInputTwistSlider.minimumValue = Float(audioInputTwistMinimum!)
        }
        if audioInputTwistMaximum != nil {
            audioInputMaximumTwistLabel.text = String(format: "%d", audioInputTwistMaximum!)
            audioInputTwistSlider.maximumValue = Float(audioInputTwistMaximum!)
        }
        if audioInputGain != nil {
            audioInputGainLabel.text = String(format: "%ddB", audioInputGain!)
            audioInputGainSlider.value = Float(audioInputGain!)
        }
        if audioInputTwist != nil {
            audioInputTwistLabel.text = String(format: "%ddB", audioInputTwist!)
            audioInputTwistSlider.value = Float(audioInputTwist!)
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.bleReceive),
            name: BLECentralViewController.bleDataReceiveNotification,
            object: nil)
        print("bleDataReceiveNotification subscribed")
/*
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.tncInputLevelNotification),
            name: TncConfigMenuViewController.tncInputLevelNotification,
            object: nil)
*/
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.StreamInputLevel())

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Stop streaming input volume levels
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.PollInputLevel())
/*
        NotificationCenter.default.removeObserver(
            self,
            name: TncConfigMenuViewController.tncInputLevelNotification,
            object: nil)
*/
        NotificationCenter.default.removeObserver(
            self,
            name: BLECentralViewController.bleDataReceiveNotification,
            object: nil)
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
            name: UIApplication.willResignActiveNotification,
            object: nil)
    }
    
    @objc func willResignActive(notification: NSNotification)
    {
        print("AudioInputViewController.willResignActive")
        // Stop streaming input volume levels
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.PollInputLevel())
        
        disconnectBle()
    }
    
    @objc func didBecomeActive(notification: NSNotification)
    {
        if blePeripheral == nil {
            self.navigationController?.popToRootViewController(animated: false)
        }
        
        print("AudioInputViewController.didBecomeActive")
        // Resume streaming input volume levels
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.StreamInputLevel())
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

    /*
     * Cannot use the TncConfigMenuViewController for audio updates because
     * the latency from the double-hop through the NotificationCenter is way
     * too high (at least on the iPhone 4S this was initially tested on).
     * Instead, we subscribe directly to the posted notification data.  This
     * should be OK because the only notifications arriving at this point
     * are ones pertinent for this ViewController.
    */
    @objc func bleReceive(notification: NSNotification)
    {
        let data = notification.object as! Data
        let packets = slipDecoder.decode(incoming: data)
        for packet in packets {
            let kiss: KissPacketDecoder
            do {
                try kiss = KissPacketDecoder(incoming: packet)
                if kiss.isHardwareType() {
                    if kiss.getHardwareType()! == .INPUT_LEVEL {
                        if let level = kiss.asUInt8() {
                            updateInputLevel(level: level)
                        }
                    } else if kiss.getHardwareType()! == .INPUT_GAIN {
                        if let gain = kiss.asUInt16() {
                            updateInputGain(value: Int16(bitPattern: gain))
                        }
                    } else if kiss.getHardwareType()! == .INPUT_TWIST {
                        if let twist = kiss.asUInt8() {
                            updateInputTwist(value: Int8(bitPattern: twist))
                        }
                    }
                }
            } catch {
                print("invalid KISS packet received: \((data.hexEncodedString() as String))")
                continue
            }
        }
    }

    func updateInputLevel(level: UInt8) {
        
        let logLevel = (log(Float(level)) / log2) / 8.0
        audioInputLevelBar.progress = max(0.0, min(1.0, logLevel))
        
        if audioInputLevelBar.progress < (0.75) {
            audioInputLevelBar.progressTintColor = UIColor.red
        } else if audioInputLevelBar.progress < (7.0 / 8.0) {
            audioInputLevelBar.progressTintColor = UIColor.orange
        } else {
            audioInputLevelBar.progressTintColor = UIColor.green
        }
    }

    @objc public func tncInputLevelNotification(notification : NSNotification) {
        if let packet = notification.object as? KissPacketDecoder {
            if let value = packet.asUInt8() {
                updateInputLevel(level: value)
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
