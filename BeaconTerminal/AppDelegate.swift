import UIKit
import RealmSwift
import Material
import XCGLogger
import SwiftyJSON
import Nutella

let DEBUG = true
let SIMULATOR = true

// localhost || remote
let HOST = "localhost"

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

var realm: Realm?

func dispatch_on_main(block: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), block)
}

func getAppDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NutellaDelegate {
    
    var window: UIWindow?
    var realmDataController : RealmDataController?
    var nutella: Nutella?
    
    let bottomNavigationController: BottomNavigationController = BottomNavigationController()
    
    
    var beaconIDs = [
        BeaconID(index: 0, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 54220, minor: 25460, beaconColor: MaterialColor.pink.base),
        BeaconID(index: 1, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 13198, minor: 13180, beaconColor: MaterialColor.yellow.base),
        BeaconID(index: 2, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 15252, minor: 24173, beaconColor: MaterialColor.green.base)
    ]
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        ESTConfig.setupAppID("location-configuration-07n", andAppToken: "f7532cffe8a1a28f9b1ca1345f1d647e")
        
        setupDB()
        setupNutellaConnection(HOST)
        
        UIView.hr_setToastThemeColor(color: UIColor.grayColor())

//        UINavigationBar.appearance().barTintColor = UIColor(red: 234.0/255.0, green: 46.0/255.0, blue: 73.0/255.0, alpha: 1.0)
//        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
//        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
//        
   
        
        //        let bottomNavigationController: AppBottomNavigationController = AppBottomNavigationController()
        //        let navigationController: AppNavigationController = AppNavigationController(rootViewController: bottomNavigationController)
        //        let menuController: AppMenuController = AppMenuController(rootViewController: navigationController)
        //        let navigationDrawerController: AppNavigationDrawerController = AppNavigationDrawerController(rootViewController: menuController, leftViewController: AppLeftViewController())
        
        // Create controllers from storyboards
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
        mainViewController.changeApplicationState(ApplicationState.PLACE_GROUP)
        let sideViewController = storyboard.instantiateViewControllerWithIdentifier("sideViewController") as! SideViewController
        let scratchPadViewController = storyboard.instantiateViewControllerWithIdentifier("scratchPadViewController") as! ScratchPadViewController
        
        
        //tabbar
        
        bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController]
        bottomNavigationController.selectedIndex = 0
        bottomNavigationController.tabBar.tintColor = UIColor.whiteColor()
        bottomNavigationController.tabBar.backgroundColor = UIColor.blackColor()
        bottomNavigationController.tabBar.itemPositioning = UITabBarItemPositioning.Automatic
        
        //create top navigationbar
        let navigationController: AppNavigationController = AppNavigationController(rootViewController: bottomNavigationController)
        // create drawer
        let drawerController = AppNavigationDrawerController(rootViewController: navigationController, leftViewController:sideViewController)
        
        
        // Configure the window with the SideNavigationController as the root view controller
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window?.rootViewController = drawerController
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func setupDB() {
        
        if SIMULATOR {
            let testRealmURL = NSURL(fileURLWithPath: "/Users/aperritano/Desktop/Realm/BeaconTerminalRealm.realm")
            try! realm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
        } else {
            //TODO
            //device config
            let testRealmURL = NSURL(fileURLWithPath: "/Users/aperritano/Desktop/Realm/BeaconTerminalRealm.realm")
            try! realm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
        }
        
        realmDataController = RealmDataController(realm: realm!)
        
        if DEBUG {
            if let realm = realm {
                realm.beginWrite()
                realm.deleteAll()
                try! realm.commitWrite()
            }
        }
        
        //checks
        //nutella config
        realmDataController?.checkNutellaConfigs()
        realmDataController?.checkGroups()
    }
    
    func setupNutellaConnection(host: String) {
        
        let nutellaConfigs : Results<NutellaConfig> = realm!.objects(NutellaConfig).filter("id = '\(host)'")
        
        if nutellaConfigs.count > 0 {
            
            let config = nutellaConfigs[0]
            
            nutella = Nutella(brokerHostname: config.host!,
                                   appId: config.appId!,
                                   runId: config.runId!,
                                   componentId: config.componentId!)
            nutella?.netDelegate = self
            nutella?.resourceId = config.resourceId
            
            for channel in config.outChannels{
                nutella?.net.subscribe(channel.name!)
            }
            
            nutella?.net.publish("echo_in", message: "READY!")
        }
    }
    
    func showToast(message: String) {
        if let presentWindow = UIApplication.sharedApplication().keyWindow {
                presentWindow.makeToast(message: message, duration: 3.0, position: HRToastPositionTop)
        }
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

extension AppDelegate: NutellaNetDelegate {
    
    /**
     Called when a message is received from a publish.
     
     - parameter channel: The name of the Nutella chennal on which the message is received.
     - parameter message: The message.
     - parameter from: The actor name of the client that sent the message.
     */
    func messageReceived(channel: String, message: AnyObject, componentId: String?, resourceId: String?) {
        if let message = message as? String, componentId = componentId, resourceId = resourceId {
            let s = "messageReceived \(channel) message: \(message) componentId: \(componentId) resourceId: \(resourceId)"
            LOG.debug(s)
            self.showToast(s)
        }
    }
    
    /**
     A response to a previos request is received.
     
     - parameter channelName: The Nutella channel on which the message is received.
     - parameter requestName: The optional name of request.
     - parameter response: The dictionary/array/string containing the JSON representation.
     */
    func responseReceived(channelName: String, requestName: String?, response: AnyObject) {
        if let response = response as? String, requestName = requestName {
            let s = "responseReceived \(channelName) requestName: \(requestName) response: \(response)"
            LOG.debug(s)
            self.showToast(s)
        }
    }
    
    /**
     A request is received on a Nutella channel that was previously handled (with the handleRequest).
     
     - parameter channelName: The name of the Nutella chennal on which the request is received.
     - parameter request: The dictionary/array/string containing the JSON representation of the request.
     */
    func requestReceived(channelName: String, request: AnyObject?, componentId: String?, resourceId: String?) -> AnyObject? {
        
        if let request = request as? String, resourceId = resourceId, componentId = componentId {
            let s = "responseReceived \(channelName) request: \(request) componentId: \(componentId) resourceId: \(resourceId)"
            LOG.debug(s)
            self.showToast(s)
        }
        
        return nil
    }
}

extension AppDelegate: NutellaLocationDelegate {
    func resourceUpdated(resource: NLManagedResource) {
        
    }
    func resourceEntered(dynamicResource: NLManagedResource, staticResource: NLManagedResource) {
        
    }
    func resourceExited(dynamicResource: NLManagedResource, staticResource: NLManagedResource) {
        
    }
    
    func ready() {
        print("NutellaLocationDelegate:READY")
        //self.nutella?.net.subscribe("echo_out")
        //    })
        
        //        if let nutella = self.nutella {
        //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        //                // ... do any setup ...
        //            nutella.net.subscribe("echo_out")            })
        //         
        //        }
        
    }
}


