//
//  BeaconTerminalTests.swift
//  BeaconTerminalTests
//
//  Created by Anthony Perritano on 4/30/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import XCTest

class BeaconTerminalTests: XCTestCase {
    

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testHabitatCreate() {
        
//        let path = NSBundle.mainBundle().pathForResource("wallcology_configuration", ofType: "json")
//        let jsonData = NSData(contentsOfFile:path!)
//        let json = JSON(data: jsonData!)
//        //print(json["habitats"])
//        
//        //            "name": "Habitat 1",
//        //            "index": 0,
//        //            "temperature": 0,
//        //            "pipelength": 0,
//        //            "brickarea": 0
//        
//        if let habitats = json["habitats"].array {
//            
//            var i = 0
//            for item in habitats {
//                
//                let habitat = Habitat()
//                
//                //habitat.id = i
//                
//                if let temp = item["temperature"].int {
//                    habitat.temperature = temp
//                }
//                
//                if let pl = item["pipelength"].int {
//                    habitat.pipelength = pl
//                }
//                
//                if let ba = item["brickarea"].int {
//                    habitat.brickarea = ba
//                }
//                
//                if let name = item["name"].string {
//                    habitat.name = name
//                }
//                
//                // Save your object
//                realm!.beginWrite()
//                realm!.add(habitat)
//                try! realm!.commitWrite()
//                
//                i += 0
//            }
//        }

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
