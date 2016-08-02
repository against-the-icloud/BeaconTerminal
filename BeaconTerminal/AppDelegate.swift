import UIKit
import RealmSwift
import Material
import XCGLogger
//import Nutella
import Transporter

let DEBUG = true
let REFRESH_DB = false

// localhost || remote
let HOST = "localhost"

let LOG: XCGLogger = {
    
    // Setup XCGLogger
    let LOG = XCGLogger.defaultInstance()
    LOG.xcodeColorsEnabled = true // Or set the XcodeColors environment variable in your scheme to YES
    LOG.xcodeColors = [
        .verbose: .lightGrey,
        .debug: .red,
        .info: .darkGreen,
        .warning: .orange,
        .error: XCGLogger.XcodeColor(fg: UIColor.red(), bg: UIColor.white()), // Optionally use a UIColor
        .severe: XCGLogger.XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0)) // Optionally use RGB values directly
    ]
    return LOG
}()

//state machine

enum ApplicationState {
    case start
    case placeTerminal
    case placeGroup
    case objectGroup
}

//init states
let placeTerminalState = State(ApplicationState.placeTerminal)
let placeGroupState = State(ApplicationState.placeGroup)
let objectGroupState = State(ApplicationState.objectGroup)
let applicationStateMachine = StateMachine(initialState: placeGroupState, states: [objectGroupState,placeTerminalState])
//init events

let placeTerminalEvent = Event(name: "placeTerminal", sourceValues: [ApplicationState.objectGroup, ApplicationState.placeGroup],
                               destinationValue: ApplicationState.placeTerminal)

let placeGroupEvent = Event(name: "placeGroup", sourceValues: [ApplicationState.objectGroup, ApplicationState.placeTerminal], destinationValue: ApplicationState.placeGroup)
let objectGroupEvent = Event(name: "objectGroup", sourceValues: [ApplicationState.placeGroup, ApplicationState.placeTerminal], destinationValue: ApplicationState.objectGroup)

var realmDataController : RealmDataController?

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
}

var realm: Realm?

func dispatch_on_main(_ block: ()->()) {
    DispatchQueue.main.async(execute: block)
}

func getAppDelegate() -> AppDelegate {
    return UIApplication.shared().delegate as! AppDelegate
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate { /* NutellaDelegate */
    
    var window: UIWindow?
    //var nutella: Nutella?
    var collectionView: UICollectionView?
    var speciesViewController: SpeciesMenuViewController = SpeciesMenuViewController()
    
    let bottomNavigationController: AppBottomNavigationController = AppBottomNavigationController()
    
    var beaconIDs = [
        BeaconID(index: 0, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 54220, minor: 25460, beaconColor: Color.pink.base),
        BeaconID(index: 1, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 13198, minor: 13180, beaconColor: Color.yellow.base),
        BeaconID(index: 2, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 15252, minor: 24173, beaconColor: Color.green.base)
    ]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        ESTConfig.setupAppID("location-configuration-07n", andAppToken: "f7532cffe8a1a28f9b1ca1345f1d647e")
        
        prepareDB()
        //setupNutellaConnection(HOST)
        
        initStateMachine()
        
        prepareViews()
                
        UIView.hr_setToastThemeColor(UIColor.black())
        
        return true
    }
    
    
    func prepareViews() {
        
        // Configure the window with the SideNavigationController as the root view controller
        window = UIWindow(frame:UIScreen.main().bounds)
        window?.rootViewController = prepareSubviews()
        window?.makeKeyAndVisible()
        
        //species
        
    }
    
    func prepareSubviews() -> AppNavigationDrawerController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
        let sideViewController = storyboard.instantiateViewController(withIdentifier: "sideViewController") as! SideViewController
        let scratchPadViewController = storyboard.instantiateViewController(withIdentifier: "scratchPadViewController") as! ScratchPadViewController
        
        let navigationController: AppNavigationController = AppNavigationController(rootViewController: bottomNavigationController)
        
        // create drawer
        
        let navigationDrawerController = AppNavigationDrawerController(rootViewController: navigationController, leftViewController:sideViewController)
        
        //tabbar
        
        bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController]
        bottomNavigationController.selectedIndex = 0
        bottomNavigationController.tabBar.tintColor = UIColor.black()
        bottomNavigationController.tabBar.backgroundColor = UIColor.white()
        bottomNavigationController.tabBar.itemPositioning = UITabBarItemPositioning.automatic
        
        return navigationDrawerController
    }
    
    func prepareDB() {
        
        if Platform.isSimulator {
            let testRealmURL = URL(fileURLWithPath: "/Users/aperritano/Desktop/Realm/BeaconTerminalRealm.realm")
            try! realm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
        } else {
            //TODO
            //device config
            try! realm = Realm(configuration: Realm.Configuration(inMemoryIdentifier: "InMemoryRealm"))
        }
        
        realmDataController = RealmDataController(realm: realm!)
        
        if REFRESH_DB {
            if let realm = realmDataController?.realm {
                realm.beginWrite()
                realm.deleteAllObjects()
                try! realm.commitWrite()
            }
            
            //checks
            //nutella config
            //            realmDataController?.checkNutellaConfigs()
           _ = realmDataController?.checkGroups()
        }
        
    }
    
    //    func setupNutellaConnection(_ host: String) {
    //
    //        let nutellaConfigs : Results<NutellaConfig> = realm!.objects(NutellaConfig).filter("id = '\(host)'")
    //
    //        if nutellaConfigs.count > 0 {
    //
    //            let config = nutellaConfigs[0]
    //
    //            nutella = Nutella(brokerHostname: config.host!,
    //                              appId: config.appId!,
    //                              runId: config.runId!,
    //                              componentId: config.componentId!)
    //            nutella?.netDelegate = self
    //            nutella?.resourceId = config.resourceId
    //
    //            for channel in config.outChannels{
    //                nutella?.net.subscribe(channel.name!)
    //            }
    //
    //            nutella?.net.publish("echo_in", message: "READY!")
    //        }
    //    }
    
    func makeToast(_ message: String) {
        if let presentWindow = UIApplication.shared().keyWindow {
            presentWindow.makeToast(message: message, duration: 3.0, position: HRToastPositionTop)
        }
    }
    
    func makeToast(_ message: String, duration: Double = 3.0, position: AnyObject) {
        if let presentWindow = UIApplication.shared().keyWindow {
            presentWindow.makeToast(message: message, duration: duration, position: HRToastPositionTop)
        }
    }
    
    // MARK: StateMachine
    func initStateMachine() {
        
        applicationStateMachine.addEvents([placeTerminalEvent, placeGroupEvent, objectGroupEvent])
        
        placeTerminalState.didEnterState = { state in self.preparePlaceTerminal() }
        placeGroupState.didEnterState = { state in self.preparePlaceGroup() }
        objectGroupState.didEnterState = { state in self.prepareObjectGroup() }
        
        //init with group termainal
        if !applicationStateMachine.fireEvent(objectGroupEvent).successful {
            LOG.debug("We didn't transition")
        }
    }
    
    func changeSystemStateTo(_ state: ApplicationState) {
        
        
        switch state {
        case .placeGroup:
            if !applicationStateMachine.fireEvent(placeGroupEvent).successful {
                LOG.debug("We didn't transition")
            }
        case .placeTerminal:
            if !applicationStateMachine.fireEvent(placeTerminalEvent).successful {
                LOG.debug("We didn't transition")
            }
        case .objectGroup:
            if !applicationStateMachine.fireEvent(objectGroupEvent).successful {
                LOG.debug("We didn't transition")
            }
        default:
            break
        }
    }
    
    func checkApplicationState() -> ApplicationState {
        return applicationStateMachine.currentState.value
    }
    
    func preparePlaceTerminal() {
    }
    
    func preparePlaceGroup() {
        bottomNavigationController.changeGroupAndSectionTitles((realmDataController?.currentGroup?.groupTitle)!, newSectionTitle: (realmDataController?.currentSection)!)
        
        
    }
    
    func prepareObjectGroup() {
        
        if let group = realmDataController?.currentGroup {
            bottomNavigationController.changeGroupAndSectionTitles(group.groupTitle, newSectionTitle: realmDataController?.currentSection)
        }
        
        
    }
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

//extension AppDelegate: NutellaNetDelegate {
//
//    /**
//     Called when a message is received from a publish.
//
//     - parameter channel: The name of the Nutella chennal on which the message is received.
//     - parameter message: The message.
//     - parameter from: The actor name of the client that sent the message.
//     */
//    func messageReceived(_ channel: String, message: AnyObject, componentId: String?, resourceId: String?) {
//        if let message = message as? String, componentId = componentId, resourceId = resourceId {
//            let s = "messageReceived \(channel) message: \(message) componentId: \(componentId) resourceId: \(resourceId)"
//            LOG.debug(s)
//            self.makeToast(s)
//        }
//    }
//
//    /**
//     A response to a previos request is received.
//
//     - parameter channelName: The Nutella channel on which the message is received.
//     - parameter requestName: The optional name of request.
//     - parameter response: The dictionary/array/string containing the JSON representation.
//     */
//    func responseReceived(_ channelName: String, requestName: String?, response: AnyObject) {
//        if let response = response as? String, requestName = requestName {
//            let s = "responseReceived \(channelName) requestName: \(requestName) response: \(response)"
//            LOG.debug(s)
//            self.makeToast(s)
//        }
//    }
//
//    /**
//     A request is received on a Nutella channel that was previously handled (with the handleRequest).
//
//     - parameter channelName: The name of the Nutella chennal on which the request is received.
//     - parameter request: The dictionary/array/string containing the JSON representation of the request.
//     */
//    func requestReceived(_ channelName: String, request: AnyObject?, componentId: String?, resourceId: String?) -> AnyObject? {
//
//        if let request = request as? String, resourceId = resourceId, componentId = componentId {
//            let s = "responseReceived \(channelName) request: \(request) componentId: \(componentId) resourceId: \(resourceId)"
//            LOG.debug(s)
//            self.makeToast(s)
//        }
//
//        return nil
//    }
//}
//
//extension AppDelegate: NutellaLocationDelegate {
//    func resourceUpdated(_ resource: NLManagedResource) {
//
//    }
//    func resourceEntered(_ dynamicResource: NLManagedResource, staticResource: NLManagedResource) {
//
//    }
//    func resourceExited(_ dynamicResource: NLManagedResource, staticResource: NLManagedResource) {
//
//    }
//
//    func ready() {
//        print("NutellaLocationDelegate:READY")
//        //self.nutella?.net.subscribe("echo_out")
//        //    })
//
//        //        if let nutella = self.nutella {
//        //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//        //                // ... do any setup ...
//        //            nutella.net.subscribe("echo_out")            })
//        //
//        //        }
//
//    }
//}
//
//
