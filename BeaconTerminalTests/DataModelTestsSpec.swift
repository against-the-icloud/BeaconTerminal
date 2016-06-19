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
            

//
        
            var dataController: RealmDataController!
            var testRealm : Realm!
    
            beforeEach {
                let testRealmURL = NSURL(fileURLWithPath: "/Users/aperritano/Desktop/Realm/TestRealm.realm")
                try! testRealm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
                //try! testRealm = Realm(configuration: Realm.Configuration(inMemoryIdentifier: "test-spec"))
                dataController = RealmDataController(realm: testRealm)

            }
            afterEach{

                try! testRealm.write {
                    testRealm.deleteAll()
                }
            }
            
//
//            it("adds the SimulationConfiguration to the Realm") {
//                expect(testRealm.objects(SimulationConfiguration).count).to(equal(0))
//                
//                let simulationConfiguration = dataController.createDefaultConfiguration()
//                dataController.add(simulationConfiguration)
//                
//                expect(testRealm.objects(SimulationConfiguration).count).to(equal(1))
//            }
//            
//            it("adds observation to realm") {
//                expect(testRealm.objects(SpeciesObservation).count).to(equal(0))
//       
//
//                let speciesFrom = dataController.findSpecies(0)
//                let speciesTo = dataController.findSpecies(3)
//                //SpeciesRelationships.Producer
//
//
//
//
//                let speciesObservation = dataController.createSpeciesObservation(speciesTo!,  toSpecies: speciesFrom!, relationship: SpeciesRelationships.PRODUCER)
//                dataController.add(speciesObservation)
//                
//                expect(testRealm.objects(SpeciesObservation).count).to(equal(1))
//            }
            
            it("adds group to realm") {
                expect(testRealm.objects(Group).count).to(equal(0))
                
                let g = dataController.createTestGroup()
                dataController.add(g, shouldUpdate: false)
                LOG.debug( "JSON: \(g.toDictionary())")
                
           
                expect(testRealm.objects(Group).count).to(equal(1))
            }
        }
    }

}