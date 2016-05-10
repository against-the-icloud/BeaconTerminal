
import UIKit
import RealmSwift
import SwiftyJSON
import XCGLogger

let LOG: XCGLogger = {
    // Setup XCGLogger
    let LOG = XCGLogger.defaultInstance()
    LOG.xcodeColorsEnabled = true // Or set the XcodeColors environment variable in your scheme to YES
    LOG.xcodeColors = [
        .Verbose: .lightGrey,
        .Debug: .red,
        .Info: .darkGreen,
        .Warning: .orange,
        .Error: XCGLogger.XcodeColor(fg: UIColor.redColor(), bg: UIColor.whiteColor()), // Optionally use a UIColor
        .Severe: XCGLogger.XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0)) // Optionally use RGB values directly
    ]
    return LOG
}()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var realm: Realm?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ESTConfig.setupAppID("location-configuration-07n", andAppToken: "f7532cffe8a1a28f9b1ca1345f1d647e")
        
        
        do {
            try NSFileManager.defaultManager().removeItemAtURL(Realm.Configuration.defaultConfiguration.fileURL!)
            
            
        } catch {}
        
        
        realm = try! Realm() // Create realm pointing to default file
        
        
        //createDataStructure()
        
        
        LOG.debug("\(Realm.Configuration.defaultConfiguration.fileURL!)")
        
        
        return true
    }
    
    func createDataStructure() {
        
        do {
            let path = NSBundle.mainBundle().pathForResource("wallcology_configuration", ofType: "json")
            let jsonData = NSData(contentsOfFile:path!)
            let json = JSON(data: jsonData!)
            
            let configuration = Configutation()
            
            if let habitats = json["habitats"].array {
                
                var i = 0
                for item in habitats {
                    
                    let habitat = Habitat()
                    
                    habitat.habitatNumber = i
                    
                    if let temp = item["temperature"].int {
                        habitat.temperature = temp
                    }
                    
                    if let pl = item["pipelength"].int {
                        habitat.pipelength = pl
                    }
                    
                    if let ba = item["brickarea"].int {
                        habitat.brickarea = ba
                    }
                    
                    if let name = item["name"].string {
                        habitat.name = name
                    }
                    
                    configuration.habitats.append(habitat)
                    
                    // Persist your data easily
                    try! realm!.write {
                        realm!.add(habitat)
                    }
                    
                    i += 1
                }
            }
            
            if let critters = json["habitatItems"].array {
                for item in critters {
                    
                    let critter = Critter()
                    
                    
                    if let index = item["index"].int {
                        critter.index = index
                    }
                    
                    if let color = item["color"].string {
                        critter.color = color
                    }
                    
                    if let imgUrl = item["imgUrl"].string {
                        critter.imgUrl = imgUrl
                    }
                    
                    
                    configuration.critters.append(critter)
                    
                    // Persist your data easily
                    try! realm!.write {
                        realm!.add(critter)
                    }
                    
                }
                
            }
            try! realm!.write {
                realm!.add(configuration)
            }
            
            
            
        } catch {
            //            print("error")
            LOG.debug("error")
            //            print("error")
            LOG.debug("error")
        }
        
    }
    
    func createTestCritters() {
        let critter = Critter()
        critter.name = "blue"
        critter.imgUrl = "https://ltg.cs.uic.edu/WC/icons/species_00.svg"
        critter.color = "#FFC91B"
        
        // Save your object
        realm!.beginWrite()
        realm!.add(critter)
        try! realm!.commitWrite()
        
    }
    
    func createTestHabitat() {
        
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}