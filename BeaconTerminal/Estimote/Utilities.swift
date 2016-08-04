//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit

func estimoteCloudReachable() -> Bool {
    var address = sockaddr_in()
    address.sin_len = UInt8(sizeofValue(address))
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = in_port_t(443)
    address.sin_addr.s_addr = inet_addr("cloud.estimote.com")

    guard let reachability = withUnsafePointer(&address, {
        SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }) else {
        return false
    }

    var flags : SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(reachability, &flags) {
        return false
    }

    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)

    return isReachable && !needsConnection
}

func updateFirmwareIfUpdateAvailable(
    _ beacon: ESTDeviceLocationBeacon,
    progress: (progressPercentage: Int) -> Void,
    completion: (error: NSError?) -> Void) {

        beacon.updateFirmware(
            progress: { progressPercentage in
                DispatchQueue.main.async(execute: {
                    progress(progressPercentage: progressPercentage)
                })
            }, completion: { error in
                if error == nil || error!._code == ESTDeviceLocationBeaconError.firmwareUpdateNoUpdate.rawValue {
                    DispatchQueue.main.async(execute: {
                        completion(error: nil)
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        completion(error: error)
                    })
                }
            }
        )
}

func writeSettingsToBeacon(
    _ beacon: ESTDeviceLocationBeacon,
    settings: [ESTSettingReadWrite],
    progress: (finishedOperationsCount: Int) -> Void,
    completion: (failedOperations: [(operationIdentifier: String, error: NSError)]) -> Void) {

        var finishedOperationsCount = 0
        var failedOperations = [(operationIdentifier: String, error: NSError)]()

        let completionGenerator = { (operationIdentifier: String) ->
            ((newValue: AnyObject?, error: NSError?) -> Void) in return { _, maybeError in
                finishedOperationsCount += 1
                if let error = maybeError {
                    failedOperations.append((operationIdentifier, error))
                }

                progress(finishedOperationsCount: finishedOperationsCount)
                if finishedOperationsCount == settings.count {
                    completion(failedOperations: failedOperations)
                }
            }
        }

        let operations = settings.map {
            operationForSetting($0, completionGenerator: completionGenerator)!
        }
        beacon.settings!.performOperations(from: operations)
}

func operationForSetting(
    _ setting: ESTSettingReadWrite,
    completionGenerator: (operationIdentifier: String) -> ((AnyObject?, NSError?) -> Void))
    -> ESTBeaconOperationProtocol! {

        return nil
//        switch setting {
//
//        case let setting as ESTSettingDeviceInfoTags:
//            return ESTCloudOperationDeviceInfoTags.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "tags"))
//
//        case let setting as ESTSettingDeviceInfoGeoLocation:
//            return ESTCloudOperationDeviceInfoGeoLocation.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "geolocation"))
//
//        case let setting as ESTSettingPowerSmartPowerModeEnable:
//            return ESTBeaconOperationPowerSmartPowerModeEnable.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "smart power mode"))
//
//        case let setting as ESTSettingIBeaconEnable:
//            return ESTBeaconOperationIBeaconEnable.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "iBeacon enabled"))
//
//        case let setting as ESTSettingIBeaconInterval:
//            return ESTBeaconOperationIBeaconInterval.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "iBeacon advertising interval"))
//
//        case let setting as ESTSettingIBeaconMajor:
//            return ESTBeaconOperationIBeaconMajor.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "iBeacon major"))
//
//        case let setting as ESTSettingIBeaconMinor:
//            return ESTBeaconOperationIBeaconMinor.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "iBeacon minor"))
//
//        case let setting as ESTSettingIBeaconNonStrictMode:
//            return ESTCloudOperationIBeaconNonStrictMode.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "iBeacon non-strict mode"))
//
//        case let setting as ESTSettingIBeaconPower:
//            return ESTBeaconOperationIBeaconPower.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "iBeacon transmit power"))
//
//        case let setting as ESTSettingIBeaconProximityUUID:
//            return ESTBeaconOperationIBeaconProximityUUID.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "iBeacon UUID"))
//
//        case let setting as ESTSettingIBeaconSecureUUIDEnable:
//            return ESTBeaconOperationIBeaconSecureUUIDEnable.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "iBeacon Secure UUID enabled"))
//
//        case let setting as ESTSettingEstimoteTLMEnable:
//            return ESTBeaconOperationEstimoteTLMEnable.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "TLM enabled"))
//
//        case let setting as ESTSettingEstimoteTLMInterval:
//            return ESTBeaconOperationEstimoteTLMInterval.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "TLM advertising interval"))
//
//        case let setting as ESTSettingEstimoteTLMPower:
//            return ESTBeaconOperationEstimoteTLMPower.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "TLM transmit power"))
//
//        case let setting as ESTSettingConnectivityInterval:
//            return ESTBeaconOperationConnectivityInterval.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "connectivity advertising interval"))
//
//        case let setting as ESTSettingConnectivityPower:
//            return ESTBeaconOperationConnectivityPower.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "connectivity transmit power"))
//
//        case let setting as ESTSettingEstimoteLocationEnable:
//            return ESTBeaconOperationEstimoteLocationEnable.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "Estimote packet enabled"))
//
//        case let setting as ESTSettingEstimoteLocationInterval:
//            return ESTBeaconOperationEstimoteLocationInterval.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "Estimote packet advertising interval"))
//
//        case let setting as ESTSettingEstimoteLocationPower:
//            return ESTBeaconOperationEstimoteLocationPower.writeOperation(withSetting: setting,
//                completion: completionGenerator(operationIdentifier: "Estimote packet transmit power"))
//
//        default:
//            assertionFailure("Couldn't find an operation to handle writing the \(setting.dynamicType) setting. Make sure there's an appropriate case statement in the `operationForSetting:` function.")
//            return nil
//        }
}
