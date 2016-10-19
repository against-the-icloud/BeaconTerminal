//
// Please report any problems with this app template to contact@estimote.com
//


struct BeaconID: Equatable, CustomStringConvertible, Hashable {
    
    let identifier: String
    let proximityUUID: UUID
    let major: CLBeaconMajorValue
    let minor: CLBeaconMinorValue
    let speciesIndex: Int
    
    init(identifier: String, UUIDString: String =  "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: CLBeaconMajorValue, minor: CLBeaconMinorValue, withSpeciesIndex speciesIndex: Int) {
        self.identifier = identifier
        self.proximityUUID = UUID(uuidString: UUIDString)!
        self.major = major
        self.minor = minor
        self.speciesIndex = speciesIndex
    }
    
    var asString: String {
        get { return "identifier:\(identifier),proximityUUID:\(proximityUUID.uuidString), major:\(major), minor:\(minor), speciesIndex:\(speciesIndex)"
        }
    }
    
    var asBeaconRegion: CLBeaconRegion {
        get { return CLBeaconRegion(
            proximityUUID: self.proximityUUID, major: self.major, minor: self.minor,
            identifier: self.identifier) }
    }
    
    var description: String {
        get { return self.asString }
    }
    
    var hashValue: Int {
        get { return self.asString.hashValue }
    }
    
}

func ==(lhs: BeaconID, rhs: BeaconID) -> Bool {
    return lhs.identifier == rhs.identifier
        && lhs.major == rhs.major
        && lhs.minor == rhs.minor
}
/*
 extension CLBeacon {
 
 var beaconID: BeaconID {
 get { return BeaconID(
 identifier: identifier,
 major: major.uint16Value,
 minor: minor.uint16Value) }
 }
 
 }
 */
