//
//  TncConfigMenuViewControllerTableViewController.swift
//  Mobilinkd TNC Config
//
//  Created by Rob Riggs on 12/29/18.
//  Copyright © 2018 Mobilinkd LLC. All rights reserved.
//

import UIKit
import CoreBluetooth

// KISS Parameters
var txDelay : UInt8?
var persistence : UInt8?
var timeSlot : UInt8?
var duplex : Bool?

// Power Settings
var batteryLevel : UInt16?
var usbPowerOn : Bool?
var usbPowerOff : Bool?

extension UIView {
    
    func animateButtonDown() {
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    func animateButtonUp() {
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

func tncModified() {
    NotificationCenter.default.post(
        name: TncConfigMenuViewController.tncModifiedNotification,
        object: nil)
}

class TncConfigMenuViewController : UITableViewController {
    
    @IBOutlet weak var tncNameLabel: UILabel!
    @IBOutlet weak var saveSettings: UIBarButtonItem!
    @IBOutlet weak var modemSettings: UIButton!

    static let tncInputLevelNotification = NSNotification.Name(rawValue: "tncInputLevel")
    static let tncBatteryLevelNotification = NSNotification.Name(rawValue: "tncBatteryLevel")
    static let tncOutputLevelNotification = NSNotification.Name(rawValue: "tncOutputLevel")
    static let tncOutputTwistNotification = NSNotification.Name(rawValue: "tncOutputTwist")
    static let tncInputGainNotification = NSNotification.Name(rawValue: "tncInputGain")
    static let tncSquelchLevelNotification = NSNotification.Name(rawValue: "tncSquelchLevel") // Not used
    static let tncVerbosityLevelNotification = NSNotification.Name(rawValue: "tncVerbosityTwist")
    static let tncInputTwistNotification = NSNotification.Name(rawValue: "tncInputTwist")

    static let tncTxDelayNotification = NSNotification.Name(rawValue: "tncTxDelay")
    static let tncPersistenceNotification = NSNotification.Name(rawValue: "tncPersistence")
    static let tncSlotTimeNotification = NSNotification.Name(rawValue: "tncSlotTime")
    static let tncTxTailNotification = NSNotification.Name(rawValue: "tncTxTail")
    static let tncDuplexNotification = NSNotification.Name(rawValue: "tncDuplex")

    static let tncFirmwareVerionNotification = NSNotification.Name(rawValue: "tncFirmwareVersion")
    static let tncHardwareVersionNotification = NSNotification.Name(rawValue: "tncHardwareVersion")
    static let tncSerialNumberNotification = NSNotification.Name(rawValue: "tncSerialNumber")
    static let tncDateTimeNotification = NSNotification.Name(rawValue: "tncDateTime")
    static let tncConnectionTrackingNotification = NSNotification.Name(rawValue: "tncConnectionTracking")
    static let tncUsbPowerOnNotification = NSNotification.Name(rawValue: "tncUsbPowerOn")
    static let tncUsbPowerOffNotification = NSNotification.Name(rawValue: "tncUsbPowerOff")

    static let tncPttStyleNotification = NSNotification.Name(rawValue: "tncPttStyle")
    static let tncMinimumOutputTwistNotification = NSNotification.Name(rawValue: "tncMinimumOutputTwist")
    static let tncMaximumOutputTwistNotification = NSNotification.Name(rawValue: "tncMaximumOutputTwist")
    static let tncMinimumInputTwistNotification = NSNotification.Name(rawValue: "tncMinimumInputTwist")
    static let tncMaximumInputTwistNotification = NSNotification.Name(rawValue: "tncMaximumInputTwist")
    static let tncApiVersionNotification = NSNotification.Name(rawValue: "tncApiVersion")
    static let tncMinimumInputGainNotification = NSNotification.Name(rawValue: "tncMinimumInputGain")
    static let tncMaximumInputGainNotification = NSNotification.Name(rawValue: "tncMaximumInputGain")
    static let tncCapabilitiesNotification = NSNotification.Name(rawValue: "tncCapabilities")

    static let tncModifiedNotification = NSNotification.Name(rawValue: "tncModified")
    
    static let tncSupportedModemTypesNotification = NSNotification.Name(rawValue: "tncSupportedModemTYpes")
    static let tncModemTypeNotification = NSNotification.Name(rawValue: "tncModemTYpe")
    static let tncPassallNotification = NSNotification.Name(rawValue: "tncPassall")
    static let tncRxReversePolarityNotification = NSNotification.Name(rawValue: "tncRxReversePolarity")
    static let tncTxReversePolarityNotification = NSNotification.Name(rawValue: "tncTxReversePolarity")

    var mainViewController : BLECentralViewController?
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral?
    // SlipProtocolDecoder maintains state to handle packets that are split
    // across multiple MTU blocks.
    var slipDecoder = SlipProtocolDecoder()
    var hasSaveSettings = false
    
    // Audio Input
    var audioInputGainMinimum : Int16?
    var audioInputGainMaximum : Int16?
    var audioInputTwistMinimum : Int8?
    var audioInputTwistMaximum : Int8?
    var audioInputGain : Int16?
    var audioInputTwist : Int8?
    
    // Audio Output
    var pttStyle: AudioOutputViewController.PttStyle?
    var audioOutputGain : Int16?
    var audioOutputGainMinimum = Int16(0)
    var audioOutputGainMaximum = Int16(255)
    var audioOutputTwist : Int8?
    var audioOutputTwistMinimum : Int8?
    var audioOutputTwistMaximum : Int8?

    // TNC Information
    var hardwareVersion : String?
    var firmwareVersion : String?
    var macAddress : String?
    var serialNumber : String?
    var dateTime : Data?
    
    // Modem Configuration
    var supportedModemTypes : [UInt8] = []
    var modemType = UInt8(1)
    var passall : Bool?
    var rxReversePolarity : Bool?
    var txReversePolarity : Bool?

    let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToConfiguration")
        {
            if let tncInformation = segue.destination as? TncInformationViewController {
                tncInformation.hardwareVersion = hardwareVersion
                tncInformation.firmwareVersion = firmwareVersion
                tncInformation.macAddress = macAddress
                tncInformation.serialNumber = serialNumber
                if let value = dateTime {
                    tncInformation.updateDateTime(value)
                }
            }
        } else if let audioInput = segue.destination as? AudioInputViewController {
            audioInput.audioInputGain = audioInputGain
            audioInput.audioInputGainMinimum = audioInputGainMinimum
            audioInput.audioInputGainMaximum = audioInputGainMaximum
            audioInput.audioInputTwist = audioInputTwist
            audioInput.audioInputTwistMinimum = audioInputTwistMinimum
            audioInput.audioInputTwistMaximum = audioInputTwistMaximum
        } else if let audioOutput = segue.destination as? AudioOutputViewController {
            audioOutput.audioOutputGain = audioOutputGain
            audioOutput.audioOutputGainMinimum = audioOutputGainMinimum
            audioOutput.audioOutputGainMaximum = audioOutputGainMaximum
            audioOutput.audioOutputTwist = audioOutputTwist
            audioOutput.audioOutputTwistMinimum = audioOutputTwistMinimum
            audioOutput.audioOutputTwistMaximum = audioOutputTwistMaximum
            audioOutput.pttStyle = pttStyle
        } else if let modemConfig = segue.destination as? ModemConfigurationViewController {
            modemConfig.passall = passall
            modemConfig.rxReversePolarity = rxReversePolarity
            modemConfig.txReversePolarity = txReversePolarity
            modemConfig.modemType = modemType
            modemConfig.supportedModemTypes = supportedModemTypes
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isUserInteractionEnabled = false
        
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.startAnimating()
        
        tncNameLabel.text = peripheral?.name!
        modemType = 1
        supportedModemTypes = []
        passall = nil
        modemSettings.isEnabled = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.bleReceive),
            name: BLECentralViewController.bleDataReceiveNotification,
            object: nil)
        print("bleDataReceiveNotification subscribed")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.tncModified),
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
        print("tncModifiedNotification subscribed")

        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.ReadAllValues())
        print("sent ReadAllValues to TNC")

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        indicator.startAnimating()
        
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.ReadAllValues())
        print("sent ReadAllValues to TNC")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        indicator.stopAnimating()
    }

    @objc func willResignActive(notification: NSNotification)
    {
        print("TncConfigMenuViewController.willResignActive")
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.PollInputLevel())
        
        if self.isBeingPresented {
            disconnectBle()
        }
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

    deinit {
        NotificationCenter.default.removeObserver(self,
            name: BLECentralViewController.bleDataReceiveNotification,
            object: nil)
        print("bleDataReceiveNotification unsubscribed")
        NotificationCenter.default.removeObserver(
            self,
            name: TncConfigMenuViewController.tncModifiedNotification,
            object: nil)
        print("tncModifiedNotification unsubscribed")
    }
    
    @objc public func tncModified(notification: NSNotification)
    {
        print("tncModified")
        if hasSaveSettings {
            saveSettings.isEnabled = true
        }
    }
    
    func postPacket(packet: KissPacketDecoder)
    {
        if let hardware = packet.getHardwareType() {
            switch hardware {
            case .INPUT_LEVEL:
/*
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncInputLevelNotification,
                    object: packet)
*/
                break
            case .BATTERY_LEVEL:
                batteryLevel = packet.asUInt16()
                if batteryLevel != nil {
                    print("battery level packet data = \((packet.data.hexEncodedString()))")
                    print("battery level = \((batteryLevel!))")
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncBatteryLevelNotification,
                    object: packet)
                break
            case .TX_VOLUME:
                if let value = packet.asUInt16() {
                    audioOutputGain = Int16(bitPattern: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncOutputLevelNotification,
                    object: packet)
                break
            case .TX_TWIST:
                if let value = packet.asUInt8() {
                    audioOutputTwist = Int8(bitPattern: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncOutputTwistNotification,
                    object: packet)
                break
            case .INPUT_GAIN:
                if let value = packet.asUInt16() {
                    audioInputGain = Int16(bitPattern: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncInputGainNotification,
                    object: packet)
                break
            case .SQUELCH_LEVEL:
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncSquelchLevelNotification,
                    object: packet)
                break
            case .VERBOSITY:
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncVerbosityLevelNotification,
                    object: packet)
                break
            case .INPUT_TWIST:
                if let value = packet.asUInt8() {
                    audioInputTwist = Int8(bitPattern: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncInputTwistNotification,
                    object: packet)
                break
            case .TX_DELAY:
                if let value = packet.asUInt8() {
                    txDelay = value
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncTxDelayNotification,
                    object: packet)
                break
            case .PERSISTENCE:
                if let value = packet.asUInt8() {
                    persistence = value
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncPersistenceNotification,
                    object: packet)
                break
            case .SLOT_TIME:
                if let value = packet.asUInt8() {
                    timeSlot = value
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncSlotTimeNotification,
                    object: packet)
                break
            case .TX_TAIL:
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncTxTailNotification,
                    object: packet)
                break
            case .DUPLEX:
                if let value = packet.asUInt8() {
                    duplex = value != 0
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncDuplexNotification,
                    object: packet)
                break
            case .FIRMWARE_VERSION:
                firmwareVersion = packet.asString()
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncFirmwareVerionNotification,
                    object: packet)
                break
            case .HARDWARE_VERSION:
                hardwareVersion = packet.asString()
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncHardwareVersionNotification,
                    object: packet)
                break
            case .SERIAL_NUMBER:
                serialNumber = packet.asString()
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncSerialNumberNotification,
                    object: packet)
                break
            case .GET_MAC_ADDRESS:
                let data = packet.data
                if data.count >= 6 {
                    macAddress = String(
                        format: "%02X:%02X:%02X:%02X:%02X:%02X",
                        data[0], data[1], data[2], data[3], data[4], data[5])
                }
                break;
            case .DATE_TIME:
                dateTime = packet.data
                print("date time = \((dateTime!.hexEncodedString()))")
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncDateTimeNotification,
                    object: packet)
                // This is a bit of a hack.  We know this is the last bit of
                // data we will receive, so enable user interaction only
                // after this has been received.
                indicator.stopAnimating()
                tableView.isUserInteractionEnabled = true
                break
            case .CONNECTION_TRACKING:
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncConnectionTrackingNotification,
                    object: packet)
                break
            case .USB_POWER_ON:
                if let value = packet.asUInt8() {
                    usbPowerOn = (value == 1)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncUsbPowerOnNotification,
                    object: packet)
                break
            case .USB_POWER_OFF:
                if let value = packet.asUInt8() {
                    usbPowerOff = (value == 1)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncUsbPowerOffNotification,
                    object: packet)
                break
            case .PTT_CHANNEL:
                if let value = packet.asUInt8() {
                    pttStyle = AudioOutputViewController.PttStyle(rawValue: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncPttStyleNotification,
                    object: packet)
                break
            case .MIN_OUTPUT_TWIST:
                if let value = packet.asUInt8() {
                    audioOutputTwistMinimum = Int8(bitPattern: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncMinimumOutputTwistNotification,
                    object: packet)
                break
            case .MAX_OUTPUT_TWIST:
                if let value = packet.asUInt8() {
                    audioOutputTwistMaximum = Int8(bitPattern: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncMaximumOutputTwistNotification,
                    object: packet)
                break
            case .MIN_INPUT_GAIN:
                if let value = packet.asUInt16() {
                    audioInputGainMinimum = Int16(bitPattern: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncMinimumInputGainNotification,
                    object: packet)
                break
            case .MAX_INPUT_GAIN:
                if let value = packet.asUInt16() {
                    audioInputGainMaximum = Int16(bitPattern: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncMaximumInputGainNotification,
                    object: packet)
                break
            case .MIN_INPUT_TWIST:
                if let value = packet.asUInt8() {
                    audioInputTwistMinimum = Int8(bitPattern: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncMinimumInputTwistNotification,
                    object: packet)
                break
            case .MAX_INPUT_TWIST:
                if let value = packet.asUInt8() {
                    audioInputTwistMaximum = Int8(bitPattern: value)
                }
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncMaximumInputTwistNotification,
                    object: packet)
                break
            case .API_VERSION:
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncApiVersionNotification,
                    object: packet)
                break
            case .CAPABILITIES:
                if let capabilities = packet.asUInt16() {
                    if capabilities & KissPacketDecoder.Capabilities.CAP_EEPROM_SAVE.rawValue != 0 {
                        hasSaveSettings = true
                    }
                }
                print("hasSaveSettings = \((hasSaveSettings))")
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncCapabilitiesNotification,
                    object: packet)
                break
            case .PASSALL:
                if let value = packet.asUInt8() {
                    passall = (value != 0);
                }
                print("passall = \((passall!))")
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncPassallNotification,
                    object: packet)
                modemSettings.isEnabled = true
                break
            case .RX_REVERSE_POLARITY:
                if let value = packet.asUInt8() {
                    rxReversePolarity = (value != 0);
                }
                print("rxReversePolarity = \((rxReversePolarity!))")
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncRxReversePolarityNotification,
                    object: packet)
                modemSettings.isEnabled = true
                break
            case .TX_REVERSE_POLARITY:
                if let value = packet.asUInt8() {
                    txReversePolarity = (value != 0);
                }
                print("txReversePolarity = \((passall!))")
                NotificationCenter.default.post(
                    name: TncConfigMenuViewController.tncTxReversePolarityNotification,
                    object: packet)
                modemSettings.isEnabled = true
                break
            case .EXTENDED_RANGE_1:
                switch packet.getHardwareExtendedType() {
                case .GET_SUPPORTED_MODEM_TYPES:
                    supportedModemTypes = [UInt8](packet.data)
                    print("supportedModemTypes = \((packet.data.hexEncodedString()))")
                    NotificationCenter.default.post(
                        name: TncConfigMenuViewController.tncSupportedModemTypesNotification,
                        object: packet)
                    modemSettings.isEnabled = true
                   break
                case .GET_MODEM_TYPE:
                    if let value = packet.asUInt8() {
                        modemType = value
                    }
                    print("modemType = \((modemType))")
                    NotificationCenter.default.post(
                        name: TncConfigMenuViewController.tncModemTypeNotification,
                        object: packet)
                    modemSettings.isEnabled = true
                    break
                default:
                    print("extended packet type: \((packet.packetType))")
                }
                break
            }
        } else {
            print("packet type: \((packet.packetType))")
        }
    }
    
    @IBAction func saveSettings(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(
            name: BLECentralViewController.bleDataSendNotification,
            object: KissPacketEncoder.SaveEepromSettings())
        saveSettings.isEnabled = false
    }

    public func settingsChanged() {
        if hasSaveSettings {
            saveSettings.isEnabled = true
        }
    }
    
    @objc func bleReceive(notification: NSNotification)
    {
        // print("bleReceive")
        // unpack data
        let data = notification.object as! Data
        let packets = slipDecoder.decode(incoming: data)
        for packet in packets {
            let kiss: KissPacketDecoder
            do {
                try kiss = KissPacketDecoder(incoming: packet)
                postPacket(packet: kiss)
            } catch {
                print("invalid KISS packet received: \((data.hexEncodedString() as String))")
                continue
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
