//
//  BeaconTerminalModelTests.swift
//  BeaconTerminalModelTests
//
//  Created by Anthony Perritano on 9/2/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import XCTest
import RealmSwift
import Nutella
@testable import BeaconTerminal

class BeaconTerminalModelTests: XCTestCase, NutellaNetDelegate {
    
    var simConfig: SimulationConfiguration?
    override func setUp() {
        super.setUp()
        
        let testRealmURL = URL(fileURLWithPath: "/Users/aperritano/Desktop/Realm/BeaconTerminalRealm.realm")
        try! realm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
        
        realmDataController = RealmDataController()
        realmDataController?.deleteAllConfigurationAndGroups()
        let _ = realmDataController?.parseUserGroupConfigurationJson(withSimConfig: (realmDataController?.parseSimulationConfigurationJson())!)

        //_ = self.realmDataController.parseUserGroupConfigurationJson(withSimConfig: self.realmDataController.parseSimulationConfigurationJson())
        //elf.realmDataController.generateTestData()
        self.setupNutella()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    func setupNutella() {
        _ = realmDataController?.validateNutellaConfiguration()
        let nutellaConfig : Results<NutellaConfig> = realm!.allObjects(ofType: NutellaConfig.self)
        
        
        if let config = nutellaConfig.first {
            
            if let host = config.hosts.filter(using: "id = '\(HOST)'").first {
                
                nutella = Nutella(brokerHostname: host.url!,
                                  appId: host.appId!,
                                  runId: host.runId!,
                                  componentId: host.componentId!)
                nutella?.netDelegate = self
                nutella?.resourceId = host.resourceId
                nutella?.net.subscribe("note_changes")
                
            }
            
        }

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    
    func testNutellaConfigurationParseJson() {
        let _ = realmDataController?.parseNutellaConfigurationJson()
    }
    
    func testSimulationConfigurationParseJson() {
        let _ = realmDataController?.parseSimulationConfigurationJson()
    }
    
    func testParseUserGroupConfigurationJson() {
        let _ = realmDataController?.parseUserGroupConfigurationJson(withSimConfig:
            (realmDataController?.parseSimulationConfigurationJson())!)
    }
    
    func testPopulateData() {
        realmDataController?.deleteAllUserData()
        let _ = realmDataController?.parseUserGroupConfigurationJson(withSimConfig: (realmDataController?.parseSimulationConfigurationJson())!)
       // realmDataController?.importJsonDB(forSectionName: "DEFAULT", withJson: nil)
    }
    
    func testExportJsonWithPath() {
        let _ = realmDataController?.parseUserGroupConfigurationJson(withSimConfig: (realmDataController?.parseSimulationConfigurationJson())!)
        realmDataController?.generateTestData()
        
        realmDataController?.exportSection(withName: "DEFAULT", andFilePath: "/Users/aperritano/Desktop/test_data.json")
    }
    
    func testExportJsonWithNutella() {
        
        
        let defaultSection = realm?.section(withName: "DEFAULT")
        
        for group in (defaultSection?.groups)! {
            for so in group.speciesObservations {
                
                sleep(1)
                
                LOG.debug("sending out SO with group \(so.groupIndex) and species \(so.fromSpecies?.index)")
                let dict = so.toDictionary()
                let json = JSON(dict)
                let jsonObject: Any = json.object
                nutella?.net.asyncRequest("save_note", message: jsonObject as AnyObject, requestName: "save_note")
            }
        }
    }
    
    func testSimulator() {
        realmDataController?.deleteAllConfigurationAndGroups()
        _ = realmDataController?.parseUserGroupConfigurationJson(withSimConfig: (realmDataController?.parseSimulationConfigurationJson())!)
        
        
       // realmDataController?.importJsonDB(forSectionName: "DEFAULT", withJson: nil)
        
        if let soResults = realm?.speciesObservation(withFromSpeciesIndex: 1) {
            LOG.debug("so results \(soResults.count)")
        }
        
        
        //        _ = realmDataController.findSpecies(withSpeciesIndex: 0)
        //
        //        for so in speciesObservations {
        //            if so.fromSpecies?.index == 1 {
        //                sendSpeciesObversations(speciesObervation: so)
        //            }
        //        }
    }
    
    
    func testRetrieveSpeciesNutella() {        
        var dict = [String:String]()
        dict["speciesIndex"] = "\(1)"
        let json = JSON(dict)
        let jsonObject: Any = json.object
        nutella?.net.asyncRequest("all_notes_with_species", message: jsonObject as AnyObject, requestName: "all_notes_with_species")
        
    }
    
    
    func testSaveNote() {
        
        nutella?.netDelegate = self

      // realmDataController?.importJsonDB(testExportJsonWithNutella()
        

        
//        if let soResults = realm?.speciesObservation(withFromSpeciesIndex: 1) {
//            LOG.debug("so results \(soResults.count)")
//            
//            for so in soResults {
//                
//                //let block = DispatchWorkItem {
//                    let json = JSON(so.toDictionary())
//                    let jsonObject: Any = json.object
//                    nutella?.net.asyncRequest("save_note", message: jsonObject as AnyObject, requestName: "save_note")
//                    LOG.debug("MESSAGE SENT")
//                    sleep(1)
//               // }
//                
//               // DispatchQueue.main.async(execute: block)
//            }
//    
//        }


    }
    
    func sendSpeciesObversations(speciesObervation: SpeciesObservation) {
       
        LOG.debug("sending out SO with group \(speciesObervation.groupIndex) and species \(speciesObervation.fromSpecies?.index)")
        let dict = speciesObervation.toDictionary()
        let json = JSON(dict)
        let jsonObject: Any = json.object
        nutella?.net.asyncRequest("save_note", message: jsonObject as AnyObject, requestName: "save_note")
        
        sleep(5)
    }
    
    
}

extension BeaconTerminalModelTests {
    
    /**
     Called when a message is received from a publish.
     
     - parameter channel: The name of the Nutella chennal on which the message is received.
     - parameter message: The message.
     - parameter from: The actor name of the client that sent the message.
     */
    func messageReceived(_ channel: String, message: AnyObject, componentId: String?, resourceId: String?) {
        var nutellaUpdate = NutellaUpdate()
        nutellaUpdate.channel = channel
        nutellaUpdate.message = message
        nutellaUpdate.updateType = .message
        realmDataController?.processNutellaUpdate(nutellaUpdate: nutellaUpdate)
    }
    
    /**
     A response to a previos request is received.
     
     - parameter channelName: The Nutella channel on which the message is received.
     - parameter requestName: The optional name of request.
     - parameter response: The dictionary/array/string containing the JSON representation.
     */
    func responseReceived(_ channelName: String, requestName: String?, response: AnyObject) {
        var nutellaUpdate = NutellaUpdate()
        nutellaUpdate.channel = channelName
        nutellaUpdate.message = response
        nutellaUpdate.response =  response
        nutellaUpdate.updateType = .response
        realmDataController?.processNutellaUpdate(nutellaUpdate: nutellaUpdate)
    }
    
    /**
     A request is received on a Nutella channel that was previously handled (with the handleRequest).
     
     - parameter channelName: The name of the Nutella chennal on which the request is received.
     - parameter request: The dictionary/array/string containing the JSON representation of the request.
     */
    func requestReceived(_ channelName: String, request: AnyObject?, componentId: String?, resourceId: String?) -> AnyObject? {
        //not used
        return nil
    }
}

