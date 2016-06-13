//
//  DataModelTestsSpec.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 6/13/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RealmSwift
@testable import BeaconTerminal
//import testing_realm

class DataModelTestSpec: QuickSpec {
    
    //let realm = Realm() // <- the default realm
    
    override func spec() {
        describe("RealmDataController") {
            
            let testRealmURL = NSURL(fileURLWithPath: "/Users/aperritano/Desktop/TestRealm.realm")

        
            var dataController: RealmDataController!
            var testRealm : Realm!
           
            
            beforeEach{
//                try! testRealm = Realm(configuration: Realm.Configuration(inMemoryIdentifier: "realm-data-controller-apec"))
                try! testRealm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
                dataController = RealmDataController(realm: testRealm)
                LOG.debug("\(Realm.Configuration.defaultConfiguration.fileURL)")
                
            }
            
//            afterEach {
//                try! testRealm.write {
//                    testRealm.deleteAll()
//                }
//            }
            it("adds the SimulationConfiguration to the Realm") {
                expect(testRealm.objects(SimulationConfiguration).count).to(equal(0))
                
                let simulationConfiguration = dataController.createDefaultConfiguration()
                dataController.add(simulationConfiguration)
                
                expect(testRealm.objects(SimulationConfiguration).count).to(equal(1))
            }
        }
    }

}