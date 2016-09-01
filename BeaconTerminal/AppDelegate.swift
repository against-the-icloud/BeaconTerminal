import UIKit
import RealmSwift
import Material
import XCGLogger
import Nutella
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
        .error: XCGLogger.XcodeColor(fg: UIColor.red, bg: UIColor.white()), // Optionally use a UIColor
        .severe: XCGLogger.XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0)) // Optionally use RGB values directly
    ]
    return LOG
}()

//state machine

enum ApplicationType: String {
    case start
    case placeTerminal
    case placeGroup
    case objectGroup
}

enum Tabs : String {
    case species = "Species"
    case maps = "Place Map"
    case scratchPad = "Scratch Pad"
    
    static let allValues = [species, maps, scratchPad]
}


//init states
let placeTerminalState = State(ApplicationType.placeTerminal)
let placeGroupState = State(ApplicationType.placeGroup)
let objectGroupState = State(ApplicationType.objectGroup)
let applicationStateMachine = StateMachine(initialState: placeGroupState, states: [objectGroupState,placeTerminalState])
//init events

let placeTerminalEvent = Event(name: "placeTerminal", sourceValues: [ApplicationType.objectGroup, ApplicationType.placeGroup],
                               destinationValue: ApplicationType.placeTerminal)

let placeGroupEvent = Event(name: "placeGroup", sourceValues: [ApplicationType.objectGroup, ApplicationType.placeTerminal], destinationValue: ApplicationType.placeGroup)
let objectGroupEvent = Event(name: "objectGroup", sourceValues: [ApplicationType.placeGroup, ApplicationType.placeTerminal], destinationValue: ApplicationType.objectGroup)

var realmDataController : RealmDataController?

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
}

var realm: Realm?

func dispatch_on_main(_ block: @escaping ()->()) {
    DispatchQueue.main.async(execute: block)
}

func getAppDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate { /* NutellaDelegate */
    
    var window: UIWindow?
    var nutella: Nutella?
    var collectionView: UICollectionView?
    var speciesViewController: SpeciesMenuViewController?
    var bottomNavigationController: AppBottomNavigationController?
    //    var beaconIDs = [
    //        BeaconID(index: 0, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 54220, minor: 25460, beaconColor: Color.pink.base),
    //        BeaconID(index: 1, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 13198, minor: 13180, beaconColor: Color.yellow.base),
    //        BeaconID(index: 2, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 15252, minor: 24173, beaconColor: Color.green.base)
    //    ]
    //
    
    //delegates
    weak var controlPanelDelegate: ControlPanelDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        //        ESTConfig.setupAppID("location-configuration-07n", andAppToken: "f7532cffe8a1a28f9b1ca1345f1d647e")
        
        //1.
        prepareDB()
        //2.
        prepareViews(applicationType: ApplicationType.placeTerminal)
        //3.
        setupNutellaConnection(HOST)
        
        
        
        UIView.hr_setToastThemeColor(UIColor.black())
        
        return true
    }
    
    func prepareViews(applicationType: ApplicationType) {
        window = UIWindow(frame:UIScreen.main.bounds)
        
        var application: NavigationDrawerController?
        
        switch applicationType {
        case .placeTerminal:
            initStateMachine(applicaitonState: applicationType)
            application = prepareTerminalUI()
            break
        case .placeGroup:
            initStateMachine(applicaitonState: applicationType)
            application = prepareBasicGroupUI()
            break
        default:
            //object group
            initStateMachine(applicaitonState: applicationType)
            application = prepareBasicGroupUI()
        }
        
        
        // Configure the window with the SideNavigationController as the root view controller
        window?.rootViewController = application
        window?.makeKeyAndVisible()
    }
    
    func prepareBasicGroupUI() -> NavigationDrawerController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
        let sideViewController = storyboard.instantiateViewController(withIdentifier: "sideViewController") as! SideViewController
        
        let scratchPadViewController = storyboard.instantiateViewController(withIdentifier: "scratchPadViewController") as! ScratchPadViewController
        
        bottomNavigationController = AppBottomNavigationController()
        
        let navigationController: NavigationDrawerController = NavigationDrawerController(rootViewController: bottomNavigationController!)
        navigationController.statusBarStyle = .lightContent
        
        // create drawer
        
        let navigationDrawerController = NavigationDrawerController(rootViewController: navigationController, leftViewController:sideViewController)
        
        //tabbar
        
        bottomNavigationController?.viewControllers = [mainViewController, scratchPadViewController]
        bottomNavigationController?.selectedIndex = 0
        
        sideViewController.showSelectedCell(with: checkApplicationState())
        
        return navigationDrawerController
    }
    
    func prepareTerminalUI() -> NavigationDrawerController{
        let terminalStoryboard = UIStoryboard(name: "Terminal", bundle: nil)
        let terminalViewController = terminalStoryboard.instantiateViewController(withIdentifier: "terminalMainViewController") as! TerminalMainViewController
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let sideViewController = mainStoryBoard.instantiateViewController(withIdentifier: "sideViewController") as! SideViewController
        
        let navigationController: AppNavigationController = AppNavigationController(rootViewController: terminalViewController)
        let navigationDrawerController = NavigationDrawerController(rootViewController: navigationController, leftViewController:sideViewController)
        
        navigationController.isNavigationBarHidden = true
        navigationController.statusBarStyle = .default
        
        BadgeUtil.badge(shouldShow: false)
        
        speciesViewController = SpeciesMenuViewController()
        speciesViewController!.showSpeciesMenu(showHidden: false)
        
        sideViewController.showSelectedCell(with: checkApplicationState())
        
        return navigationDrawerController
    }
    
    
    func prepareDB() {
        
        func initDB() {
            realmDataController = RealmDataController()
            
            
            if REFRESH_DB {
                if let realm = realm {
                    realm.beginWrite()
                    realm.deleteAllObjects()
                    try! realm.commitWrite()
                    
                    
                    //checks
                    //            nutella config
                    
                    //= realmDataController?.checkGroups()
                    if let symConfig = realmDataController?.loadSystemConfiguration() {
                        realmDataController?.generateTestData()
                        //let section = symConfig.sections[1]
                        //let group = section.groups[1]
                        
                        //realmDataController?.updateUser(withGroup: group, section: section)
                        //update bottombar
                        //realmDataController?.updateBottomBar(withRuntime: runtime)
                    }
                }
            }
            
        }
        
        if Platform.isSimulator {
            let testRealmURL = URL(fileURLWithPath: "/Users/aperritano/Desktop/Realm/BeaconTerminalRealm.realm")
            try! realm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
            initDB()
        } else {
            //TODO
            //device config
            try! realm = Realm(configuration: Realm.Configuration(inMemoryIdentifier: "InMemoryRealm"))
            
            initDB()
        }
        
        
        
    }
    
    func setupNutellaConnection(_ host: String) {
        realmDataController?.checkNutellaConfigs()
        let nutellaConfig : Results<NutellaConfig> = realm!.allObjects(ofType: NutellaConfig.self)
        
        if let config = nutellaConfig.first {
            
            if let host = config.hosts.filter(using: "id = '\(HOST)'").first {
                
                nutella = Nutella(brokerHostname: host.url!,
                                  appId: host.appId!,
                                  runId: host.runId!,
                                  componentId: host.componentId!)
                nutella?.netDelegate = self
                nutella?.resourceId = host.resourceId
                
                //config.
                
                let appState: ApplicationType = checkApplicationState()
                
                for condition in config.conditions {
                    if condition.id == "placeTerminal" {
                        if let channels = condition.subscribes?.components(separatedBy: ",") {
                            for channel in channels {
                                nutella?.net.subscribe(channel)
                            }
                            
                            Util.makeToast("Subscribed to \(channels)")
                        }
                        
                        
                        if let channels = condition.publishes?.components(separatedBy: ",") {
                            for channel in channels {
                                //nutella?.net.publish(channel)
                            }
                            
                            
                            Util.makeToast("Publishes on \(channels)")
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    // MARK: StateMachine
    func initStateMachine(applicaitonState: ApplicationType) {
        
        applicationStateMachine.addEvents([placeTerminalEvent, placeGroupEvent, objectGroupEvent])
        
        placeTerminalState.didEnterState = { state in self.preparePlaceTerminal() }
        placeGroupState.didEnterState = { state in self.preparePlaceGroup() }
        objectGroupState.didEnterState = { state in self.prepareObjectGroup() }
        
        switch applicaitonState {
        case .placeGroup:
            if !applicationStateMachine.fireEvent(placeGroupEvent).successful {
                LOG.debug("We didn't transition")
            }
        case .placeTerminal:
            if !applicationStateMachine.fireEvent(placeTerminalEvent).successful {
                LOG.debug("We didn't transition")
            }
        default:
            if !applicationStateMachine.fireEvent(objectGroupEvent).successful {
                LOG.debug("We didn't transition")
            }
        }
    }
    
    func changeSystemStateTo(_ state: ApplicationType) {
        
        
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
    
    func checkApplicationState() -> ApplicationType {
        return applicationStateMachine.currentState.value
    }
    
    func preparePlaceTerminal() {
        
    }
    
    func preparePlaceGroup() {
        
    }
    
    func prepareObjectGroup() {
        
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
    
    func resetDB() {
        //check nutella connection
        
        //handle_requests: all_notes
        if let nutella = self.nutella {
            
            let block = DispatchWorkItem {
                var m = "Hello Major Tom, are you receiving this? Turn the thrusters on, we're standing by"
                var dict = [String:String]()
                dict["group"] = "1"
                
                nutella.net.asyncRequest("all_notes", message: dict as AnyObject, requestName: "all_notes")
                //nutella.net.publish("all_notes", message: dict as AnyObject)
            }
            
            DispatchQueue.main.async(execute: block)
            
            
        } else {
            //we have been disconnected
        }
    }
    
    
}

extension AppDelegate: NutellaNetDelegate {
    
    /**
     Called when a message is received from a publish.
     
     - parameter channel: The name of the Nutella chennal on which the message is received.
     - parameter message: The message.
     - parameter from: The actor name of the client that sent the message.
     */
    func messageReceived(_ channel: String, message: AnyObject, componentId: String?, resourceId: String?) {
        if message != nil {
            if let componentId = componentId, let resourceId = resourceId {
                let s = "messageReceived \(channel) message: \(message) componentId: \(componentId) resourceId: \(resourceId)"
                LOG.debug("MESSAGE RECEIVED on channel \(channel)")
                LOG.debug("MESSAGE IS: \(message)")
            }
            //Util.makeToast("GOT IT")
        }
    }
    
    /**
     A response to a previos request is received.
     
     - parameter channelName: The Nutella channel on which the message is received.
     - parameter requestName: The optional name of request.
     - parameter response: The dictionary/array/string containing the JSON representation.
     */
    func responseReceived(_ channelName: String, requestName: String?, response: AnyObject) {
        if response != nil {
            if let requestName = requestName {
                let s = "responseReceived \(channelName) requestName: \(requestName) response: \(response)"
                LOG.debug("RESPONSE RECEIVED on channel \(channelName)")
                //LOG.debug("RESPONSE IS: \(response)")
                //Util.makeToast(s)
                
                let json = JSON(response)
                LOG.debug("RECIEVED ALL NOTES \(json)")
                //let noteCount = realmDataController.parseAllNotes(withJson: json)

//                if let cpd = controlPanelDelegate {
//                    cpd.resetDidFinish(withRecordCount: noteCount)
//                }
            }
        }
    }
    
    /**
     A request is received on a Nutella channel that was previously handled (with the handleRequest).
     
     - parameter channelName: The name of the Nutella chennal on which the request is received.
     - parameter request: The dictionary/array/string containing the JSON representation of the request.
     */
    func requestReceived(_ channelName: String, request: AnyObject?, componentId: String?, resourceId: String?) -> AnyObject? {
        
        if let request = request as? String, let resourceId = resourceId, let componentId = componentId {
            let s = "responseReceived \(channelName) request: \(request) componentId: \(componentId) resourceId: \(resourceId)"
            LOG.debug(s)
            Util.makeToast(s)
        }
        
        return nil
    }
}
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
