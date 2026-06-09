import Foundation
import CoreBluetooth

class BleWriteQueue {
    static let shared = BleWriteQueue()

    private var pendingWrites: [Data] = []
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.mobilinkd.blewritequeue")

    private weak var configuredPeripheral: CBPeripheral?
    private weak var configuredCharacteristic: CBCharacteristic?

    private init() {}

    /// Enqueue data to be sent. Non-blocking.
    func enqueue(_ data: Data) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.pendingWrites.append(data)
            if self.timer == nil {
                let timer = DispatchSource.makeTimerSource(flags: [], queue: self.queue)
                timer.schedule(deadline: .now() + 0.25, repeating: .infinity)
                timer.setEventHandler { [weak self] in
                    self?.flush()
                }
                timer.resume()
                self.timer = timer
            }
        }
    }

    private func flush() {
        // 1. Concatenate all pendingWrites into a single Data payload.
        var payload = Data()
        for data in pendingWrites {
            payload += data
        }
        // 2. Clear pendingWrites.
        pendingWrites.removeAll()
        // 3. Cancel the timer, set it to nil.
        timer?.cancel()
        timer = nil

        // 4. Get the peripheral and characteristic.
        let peripheral = configuredPeripheral ?? blePeripheral
        let characteristic = configuredCharacteristic ?? txCharacteristic
        guard let peripheral = peripheral, let characteristic = characteristic else {
            return
        }

        // 5. Get MTU.
        let mtu: Int
        let maxWrite = peripheral.maximumWriteValueLength(for: .withoutResponse)
        if maxWrite > 0 {
            mtu = maxWrite
        } else {
            mtu = 20
        }

        // 6. Check MTU limit.
        if payload.count > mtu {
            print("BleWriteQueue: batched payload (\(payload.count) bytes) exceeds MTU (\(mtu)), dropping batch")
            return
        }

        // 7. Write.
        peripheral.writeValue(payload, for: characteristic, type: .withoutResponse)
    }

    /// Optional: configure with peripheral/characteristic references (weak)
    func configure(peripheral: CBPeripheral?, characteristic: CBCharacteristic?) {
        queue.async { [weak self] in
            self?.configuredPeripheral = peripheral
            self?.configuredCharacteristic = characteristic
        }
    }
}
