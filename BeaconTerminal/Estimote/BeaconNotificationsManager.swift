//
// Please report any problems with this app template to contact@estimote.com
//

import UIKit
import UserNotifications

class BeaconNotificationsManager: NSObject, ESTMonitoringManagerDelegate {

    let beaconManager = ESTMonitoringManager()

    var enterMessages = [String: String]()
    var exitMessages = [String: String]()
    
    override init() {
        super.init()

        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
    }

    func enableNotificationsForBeaconID(_ beaconID: BeaconID, enterMessage: String?, exitMessage: String?) {
        let beaconRegion = beaconID.asBeaconRegion
        beaconRegion.notifyEntryStateOnDisplay = true
        beaconRegion.notifyOnExit = true
        beaconRegion.notifyOnEntry = true
        
        
        self.enterMessages[beaconRegion.identifier] = enterMessage
        self.exitMessages[beaconRegion.identifier] = exitMessage
        
    
        self.beaconManager.startMonitoring(for: beaconRegion)
        
        LOG.debug("START MONITORING \(beaconRegion)")

        
    }
    
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        if let message = self.enterMessages[region.identifier] {
            
            self.showNotificationWithMessage(message)
            
            LOG.debug("didEnter \(region)")
            
            if let minorSpeciesIndex = region.minor?.intValue {
                //adjust because these ids can't be start 0
                let speciesIndex = minorSpeciesIndex - 1
                
                let gim = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true)
                
                realmDataController.syncSpeciesObservations(withIndex: speciesIndex)
                
                let banner = Banner(title: "DID ENTER", subtitle: "SPECIES \(message)", image: gim, backgroundColor: UIColor.black)
                
                banner.shouldTintImage = false
                banner.dismissesOnTap = true
                banner.dismissesOnSwipe = true
                banner.show()
                
                //four sec
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    banner.dismiss()
                }
                
                if let groupIndex = realmDataController.getRealm().runtimeGroupIndex() {
                    realmDataController.saveNutellaCondition(withCondition: "place", withActionType: "enter", withPlace: region.description, withGroupIndex: groupIndex, withSpeciesIndex: speciesIndex)
                }
            }
        }
    }
    
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
        if let message = self.exitMessages[region.identifier] {
            self.showNotificationWithMessage(message)
            LOG.debug("didExitRegion \(region)")
            
            if let minorSpeciesIndex = region.minor?.intValue {
                //adjust because these ids can't be start 0
                let speciesIndex = minorSpeciesIndex - 1
                
                let gim = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true)
                
                realmDataController.syncSpeciesObservations(withIndex: speciesIndex)
                
                let banner = Banner(title: "DID EXIT", subtitle: "SPECIES \(message)", image: gim, backgroundColor: UIColor.black)
                
                banner.shouldTintImage = false
                banner.dismissesOnTap = true
                banner.dismissesOnSwipe = true
                banner.show()
                
                //four sec
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    banner.dismiss()
                }
                
                if let groupIndex = realmDataController.getRealm().runtimeGroupIndex() {
                    realmDataController.saveNutellaCondition(withCondition: "place", withActionType: "exit", withPlace: region.description, withGroupIndex: groupIndex, withSpeciesIndex: speciesIndex)
                }
            }
            
        }
    }

    fileprivate func showNotificationWithMessage(_ message: String) {
        let notification = UILocalNotification()
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.presentLocalNotificationNow(notification)
        LOG.debug("showNotificationWithMessage SHOW NOTIFICATION")
    }
    
    func beaconManager(_ manager: Any, didChange status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            LOG.debug("Location Services are disabled for this app, which means it won't be able to detect beacons.")
            LOG.debug("didChange status \(status)")
            Util.makeToast("didChange status \(status)")

        }
    }

    func beaconManager(_ manager: Any, monitoringDidFailFor region: CLBeaconRegion?, withError error: Error) {
        LOG.debug("Monitoring failed for region: %@. Make sure that Bluetooth and Location Services are on, and that Location Services are allowed for this app. Beacons require a Bluetooth Low Energy compatible device: <http://www.bluetooth.com/Pages/Bluetooth-Smart-Devices-List.aspx>. Note that the iOS simulator doesn't support Bluetooth at all. The error was: %@ \(region?.identifier)")
    }

}
