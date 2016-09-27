//
// Please report any problems with this app template to contact@estimote.com
//

import Foundation

enum ImmediateBeaconDetectorError: Error {
    case BluetoothDisabled, Unknown
}

protocol ImmediateBeaconDetectorDelegate: class {

    func immediateBeaconDetector(immediateBeaconDetector: ImmediateBeaconDetector, didDiscoverBeacon beacon: ESTDeviceLocationBeacon)

    func immediateBeaconDetector(immediateBeaconDetector: ImmediateBeaconDetector, didFailDiscovery error: ImmediateBeaconDetectorError)

}

/**
 This class encapsulates all the logic related to detecting when a beacon has been placed immediately on the phone.
 */
class ImmediateBeaconDetector: NSObject, ESTDeviceManagerDelegate, CBCentralManagerDelegate {

    let deviceManager = ESTDeviceManager()
    var bluetoothManager: CBCentralManager!

    unowned var delegate: ImmediateBeaconDetectorDelegate

    init(delegate: ImmediateBeaconDetectorDelegate) {
        self.delegate = delegate

        super.init()

        deviceManager.delegate = self

        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }

    func start() {
        deviceManager.startDeviceDiscovery(with: ESTDeviceFilterLocationBeacon())
    }

    func stop() {
        deviceManager.stopDeviceDiscovery()
    }

    // MARK: ESTDeviceManagerDelegate

    func deviceManager(_ manager: ESTDeviceManager, didDiscover devices: [ESTDevice]) {
        let nextGenBeacons = devices as! [ESTDeviceLocationBeacon]
        let nearestBeacon = nextGenBeacons
            .map { ($0, normalizedRSSIForBeaconWithIdentifier(identifier: $0.identifier, RSSI: $0.rssi)) }
            .filter { $0.1 != nil && $0.1! >= 0 }
            .max { $0.1! < $1.1! }?.0
        if let nearestBeacon = nearestBeacon {
            delegate.immediateBeaconDetector(immediateBeaconDetector: self, didDiscoverBeacon: nearestBeacon)
        }
    }

    func deviceManagerDidFailDiscovery(_ manager: ESTDeviceManager) {
        if bluetoothManager.state != .poweredOn {
            delegate.immediateBeaconDetector(immediateBeaconDetector: self, didFailDiscovery: .BluetoothDisabled)
        } else {
            delegate.immediateBeaconDetector(immediateBeaconDetector: self, didFailDiscovery: .Unknown)
        }
    }

    // MARK: CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }

}
