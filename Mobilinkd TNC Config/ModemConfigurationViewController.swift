//
//  ModemConfigurationViewController.swift
//  Mobilinkd TNC Config
//
//  Created by Rob Riggs on 2/18/20.
//  Copyright © 2020 Mobilinkd LLC. All rights reserved.
//

import UIKit

class ModemConfigurationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var supportedModemTypes : [UInt8] = [1]
    var pickerData: [String] = ["1200 baud AFSK"]
    var modemType = UInt8(1)
    var passall : Bool?
    var rxReversePolarity : Bool?
    var txReversePolarity : Bool?
    
    class ModemType {
        var index : UInt8
        var name : String
        
        init(indexValue: UInt8, nameValue: String)
        {
            index = indexValue;
            name = nameValue
        }
    }
    
    static var modemTypes : [ModemType] = [
        ModemType(indexValue: 0, nameValue: "UNKNOWN".localized),
        ModemType(indexValue: 1, nameValue: "1200 baud AFSK".localized),
        ModemType(indexValue: 2, nameValue: "300 baud AFSK".localized),
        ModemType(indexValue: 3, nameValue: "9600 baud FSK".localized),
        ModemType(indexValue: 4, nameValue: "PSK31".localized),
        ModemType(indexValue: 5, nameValue: "M17 4-FSK".localized)
    ]
    
    @IBOutlet weak var modemTypePicker: UIPickerView!
    @IBOutlet weak var modemTypeLabel: UILabel!
    @IBOutlet weak var modemTypeHint: UILabel!
    
    @IBOutlet weak var passallSwitch: UISwitch!
    @IBOutlet weak var passallLabel: UILabel!
    @IBOutlet weak var passallHint: UILabel!
    
    @IBAction func passallSwitchChanged(_ sender: UISwitch) {
        passall = sender.isOn
        sendData(KissPacketEncoder.SetPassall(value: sender.isOn))
        tncModified()
    }
    
    @IBOutlet weak var rxReversePolaritySwitch: UISwitch!
    @IBOutlet weak var rxReversePolarityLabel: UILabel!
    @IBOutlet weak var rxReversePolarityHint: UILabel!
    
    @IBAction func rxReversePolaritySwitchChanged(_ sender: UISwitch) {
        rxReversePolarity = sender.isOn
        sendData(KissPacketEncoder.SetRxReversePolarity(value: sender.isOn))
        tncModified()
    }
    
    @IBOutlet weak var txReversePolaritySwitch: UISwitch!
    @IBOutlet weak var txReversePolarityLabel: UILabel!
    @IBOutlet weak var txReversePolarityHint: UILabel!
    
    @IBAction func txReversePolaritySwitchChanged(_ sender: UISwitch) {
        txReversePolarity = sender.isOn
        sendData(KissPacketEncoder.SetTxReversePolarity(value: sender.isOn))
        tncModified()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int)
    {
        let modemName = pickerData[row]
        if let modem = ModemConfigurationViewController.modemTypes.first(
                where: {$0.name == modemName}) {
            modemType = modem.index
            sendData(KissPacketEncoder.SetModemType(value: modemType))
            tncModified()
        } else {
            print("invalid modem selection received")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modemTypePicker.delegate = self
        modemTypePicker.dataSource = self

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
            selector: #selector(self.modemTypeNotification),
            name: TncConfigMenuViewController.tncModemTypeNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.supportedModemTypesNotification),
            name: TncConfigMenuViewController.tncSupportedModemTypesNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.passallNotification),
            name: TncConfigMenuViewController.tncPassallNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.rxReversePolarityNotification),
            name: TncConfigMenuViewController.tncRxReversePolarityNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.txReversePolarityNotification),
            name: TncConfigMenuViewController.tncTxReversePolarityNotification,
            object: nil)

        print("all modem notifications subscribed")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didLoseConnection),
            name: BLECentralViewController.bleDisconnectNotification,
            object: nil)
    }
    
    func updateSupportedModemTypes() {
        pickerData = [String]()
        
        var offset : Int?
        
        for (index, value) in supportedModemTypes.enumerated() {
            if value > ModemConfigurationViewController.modemTypes.count {
                continue
            }
            pickerData.append(
                ModemConfigurationViewController.modemTypes[Int(value)].name)
            if value == modemType {
                offset = index
            }
        }
        if let off = offset {
            modemTypePicker.selectRow(off, inComponent: 0, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if supportedModemTypes.count > 0 {
            updateSupportedModemTypes()
            self.modemTypePicker.reloadAllComponents()
        }
        
        if passall != nil {
            passallSwitch.isOn = passall!
            passallSwitch.isEnabled = true
        } else {
            passallSwitch.isEnabled = false
        }

        if rxReversePolarity != nil {
            rxReversePolaritySwitch.isOn = rxReversePolarity!
            rxReversePolaritySwitch.isEnabled = true
            rxReversePolarityLabel.isEnabled = true
            rxReversePolarityHint.isEnabled = true
        } else {
            rxReversePolaritySwitch.isEnabled = false
            rxReversePolarityLabel.isEnabled = false
            rxReversePolarityHint.isEnabled = false
        }

        if txReversePolarity != nil {
            txReversePolaritySwitch.isOn = txReversePolarity!
            txReversePolaritySwitch.isEnabled = true
            txReversePolarityLabel.isEnabled = true
            txReversePolarityHint.isEnabled = true
        } else {
            txReversePolaritySwitch.isEnabled = false
            txReversePolarityLabel.isEnabled = false
            txReversePolarityHint.isEnabled = false
        }
    }
    
    @objc func didBecomeActive(notification: NSNotification)
    {
        if blePeripheral == nil {
            self.navigationController?.popToRootViewController(animated: false)
        }
        print("ModemConfigurationViewController.didBecomeActive")
   }

    @objc func willResignActive(notification: NSNotification)
    {
        disconnectBle()
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willResignActiveNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: TncConfigMenuViewController.tncSupportedModemTypesNotification,
            object: nil)
        print("tncSupportedModemTypesNotification unsubscribed")
        NotificationCenter.default.removeObserver(
            self,
            name: TncConfigMenuViewController.tncModemTypeNotification,
            object: nil)
        print("tncModemTypeNotification unsubscribed")
        NotificationCenter.default.removeObserver(
            self,
            name: TncConfigMenuViewController.tncPassallNotification,
            object: nil)
        print("tncPassallNotification unsubscribed")
        NotificationCenter.default.removeObserver(
            self,
            name: BLECentralViewController.bleDisconnectNotification,
            object: nil)
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
    
    @objc public func supportedModemTypesNotification(notification: NSNotification)
    {
        print("supportedModemTypesNotification")
        
        if let packet = notification.object as? KissPacketDecoder {
            supportedModemTypes = [UInt8](packet.data)
            updateSupportedModemTypes()
            DispatchQueue.main.async { self.modemTypePicker.reloadAllComponents() }
        }
    }
    
    @objc public func modemTypeNotification(notification: NSNotification)
    {
        print("modemTypeNotification")
        
        if let packet = notification.object as? KissPacketDecoder {
            if let value = packet.asUInt8() {
                if ModemConfigurationViewController.modemTypes.count < value {
                    modemType = value
                    print("modem type set to " + ModemConfigurationViewController.modemTypes[Int(value)].name)
                    if supportedModemTypes.count != 0 {
                        updateSupportedModemTypes()
                        DispatchQueue.main.async { self.modemTypePicker.reloadAllComponents() }
                    }
                }
            }
        }
    }
    
    @objc public func passallNotification(notification: NSNotification)
    {
        print("passallNotification")
        
        if let packet = notification.object as? KissPacketDecoder {
            if let value = packet.asUInt8() {
                passallSwitch.isOn = (value == 1)
            }
        }
    }
    
    @objc public func rxReversePolarityNotification(notification: NSNotification)
    {
        print("rxReversePolarityNotification")
        
        if let packet = notification.object as? KissPacketDecoder {
            if let value = packet.asUInt8() {
                rxReversePolaritySwitch.isOn = (value == 1)
            }
        }
    }
    
    @objc public func txReversePolarityNotification(notification: NSNotification)
    {
        print("txReversePolarityNotification")
        
        if let packet = notification.object as? KissPacketDecoder {
            if let value = packet.asUInt8() {
                txReversePolaritySwitch.isOn = (value == 1)
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
