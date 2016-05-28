//
// Please report any problems with this app template to contact@estimote.com
//
import UIKit

struct BeaconID: Equatable, CustomStringConvertible, Hashable {

    let proximityUUID: NSUUID?
    let major: CLBeaconMajorValue?
    let minor: CLBeaconMinorValue?
    var index: Int = 0
    var beaconColor: UIColor = UIColor.blackColor()
    
    init(index: Int, hexColor: String) {
        self.index = index
        beaconColor = UIColor(hexString:hexColor)
        self.proximityUUID = nil
        self.major = nil
        self.minor = nil
    }

    init(index: Int, proximityUUID: NSUUID, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, beaconColor: UIColor) {
        self.index = index
        self.proximityUUID = proximityUUID
        self.major = major
        self.minor = minor
        self.beaconColor = beaconColor
    }
    init(proximityUUID: NSUUID, major: CLBeaconMajorValue, minor: CLBeaconMinorValue) {
        self.proximityUUID = proximityUUID
        self.major = major
        self.minor = minor
    }

    init(index: Int, UUIDString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, beaconColor: UIColor) {
        self.init(index: index, proximityUUID: NSUUID(UUIDString: UUIDString)!, major: major, minor: minor, beaconColor: beaconColor)
    }
    
    init(UUIDString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue) {
        self.init(proximityUUID: NSUUID(UUIDString: UUIDString)!, major: major, minor: minor)
    }

    var asString: String {
        get { return "\(proximityUUID!.UUIDString):\(major):\(minor)" }
    }

    var asBeaconRegion: CLBeaconRegion {
        get { return CLBeaconRegion(
            proximityUUID: self.proximityUUID!, major: self.major!, minor: self.minor!,
            identifier: self.asString) }
    }
    

    var description: String {
        get { return self.asString }
    }

    var hashValue: Int {
        get { return self.asString.hashValue }
    }
    
    var asSimpleDescription: String {
        get {
            return "\(index):\(beaconColor)"
        }
    }

}



func ==(lhs: BeaconID, rhs: BeaconID) -> Bool {
    return lhs.proximityUUID == rhs.proximityUUID
        && lhs.major == rhs.major
        && lhs.minor == rhs.minor
}

extension CLBeacon {

    var beaconID: BeaconID {
        get { return BeaconID(
            proximityUUID: proximityUUID,
            major: major.unsignedShortValue,
            minor: minor.unsignedShortValue) }
    }

}
