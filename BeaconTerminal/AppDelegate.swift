import UIKit
import RealmSwift
import Material
import XCGLogger
import Nutella
import Transporter
import Fabric
import Crashlytics
import Alamofire


let DEBUG = true
let REFRESH_DB = true
let EXPORT_DB = true

// localhost || remote
let HOST = "local"
let REMOTE = "ltg.evl.uic.edu"
let LOCAL = "127.0.0.1"
let LOCAL_IP = "10.0.1.6"
//let LOCAL_IP = "131.193.79.203"
var CURRENT_HOST = LOCAL
var SECTION_NAME = "default"

let ESTIMOTE_ID = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"

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

//Mark: State Machine

enum RealmType: String {
    case defaultDB = "DEFAULT_DB"
    case terminalDB = "TERMNAL_DB"
}

enum ApplicationType: String {
    case login = "Login"
    case placeTerminal = "PLACE TERMINAL"
    case placeGroup = "PLACE GROUP"
    case objectGroup = "ARTIFACT GROUP"
    
    static let allValues = [placeTerminal, placeGroup, objectGroup]
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
let LoginState = State(ApplicationType.login)
let applicationStateMachine = StateMachine(initialState: LoginState, states: [placeGroupState, objectGroupState,placeTerminalState])
//init events

let placeTerminalEvent = Event(name: "placeTerminal", sourceValues: [ApplicationType.login, ApplicationType.objectGroup, ApplicationType.placeGroup],
                               destinationValue: ApplicationType.placeTerminal)

let placeGroupEvent = Event(name: "placeGroup", sourceValues: [ApplicationType.login,ApplicationType.objectGroup, ApplicationType.placeTerminal], destinationValue: ApplicationType.placeGroup)
let objectGroupEvent = Event(name: "objectGroup", sourceValues: [ApplicationType.login, ApplicationType.placeGroup, ApplicationType.placeTerminal], destinationValue: ApplicationType.objectGroup)

var realmDataController : RealmDataController = RealmDataController()

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
}


//Mark: Nutella supports

enum NutellaMessageType: String {
    case request
    case response
    case message
}

enum NutellaChannelType: String {
    case allNotes = "all_notes"
    case allNotesWithSpecies = "all_notes_with_species"
    case allNotesWithGroup = "all_notes_with_group"
    case noteChanges = "note_changes"
}


struct NutellaUpdate {
    var channel: String?
    var message: Any?
    var updateType:  NutellaMessageType?
    var response: Any?
}


var beaconNotificationsManager: BeaconNotificationsManager?
let beaconIds = [BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 1),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 2),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 3),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 4),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 5),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 6),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 7),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 8),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 9),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 10),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 11),BeaconID(UUIDString: ESTIMOTE_ID, major: 1, minor: 12)]


var realm: Realm?
var terminalRealm: Realm?


var nutella: Nutella?

func dispatch_on_main(_ block: @escaping ()->()) {
    DispatchQueue.main.async(execute: block)
}

func getAppDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    let defaults = UserDefaults.standard
    
    var window: UIWindow?
    
    
    var collectionView: UICollectionView?
    var speciesViewController: SpeciesMenuViewController?
    var bottomNavigationController: AppBottomNavigationController?
    
    //delegates
    weak var controlPanelDelegate: ControlPanelDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    
        
        ESTConfig.setupAppID("wallcology-2016-emb", andAppToken: "fd9eb675b3f09982fd5c1788f7a437dd")
        //crash analytics
        Fabric.with([Crashlytics.self])
        
        realmDataController = RealmDataController()
        
        let groupNames = ["Team 1","Team 2", "Team 3","Team 4","Team 5"]
        let sectionDict = ["default":groupNames,"guest":groupNames, "6BM":groupNames,"6MT":groupNames,"6DF":groupNames]
        
        defaults.set(false, forKey: "init")
        defaults.set(sectionDict, forKey: "sections")
        defaults.synchronize()
        
        initStateMachine(applicaitonState: .login)
        
        //prepareViews(applicationType: .placeGroup)
        //getAppDelegate().changeSystemStateTo(.placeGroup)
        
        shortCircuitLogin()
        
        //prepareDB(withSectionName: SECTION_NAME)
        
        UIView.hr_setToastThemeColor(#colorLiteral(red: 0.9022639394, green: 0.9022851586, blue: 0.9022737145, alpha: 1))
        
    
        //setupConnection()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert], categories: nil))
        
        return true
    }
    
    func shortCircuitLogin() {
        
        getAppDelegate().changeSystemStateTo(.placeGroup)

        let defaults = UserDefaults.standard
        defaults.set(2, forKey: "condition")
        defaults.set("default", forKey: "sectionName")
        //defaults.set(0, forKey: "speciesIndex")
        defaults.set(0, forKey: "groupIndex")
        defaults.synchronize()
        
        // TODO: Move this to where you establish a user session


        loadCondition()
    }
    
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        let defaults = UserDefaults.standard
//        defaults.set(2, forKey: "condition")
//        defaults.set("default", forKey: "sectionName")
//        defaults.set(0, forKey: "groupIndex")
//        
        if let groupIndex = defaults.value(forKey: "groupIndex") as? Int {
            Crashlytics.sharedInstance().setIntValue(Int32(groupIndex), forKey: "groupIndex")
        }
        
        if let speciesIndex = defaults.value(forKey: "speciesIndex") as? Int {
            Crashlytics.sharedInstance().setIntValue(Int32(speciesIndex), forKey: "speciesIndex")
        }
        
        if let condition = defaults.value(forKey: "condition") as? Int {
            Crashlytics.sharedInstance().setIntValue(Int32(condition), forKey: "condition")
        }
        
        if let sectionName = defaults.value(forKey: "sectionName"){
            Crashlytics.sharedInstance().setObjectValue(sectionName, forKey: "sectionName")
        }
    }

    
    // Mark: View setup
    
    // Mark: db setup
    
    func loadCondition() {
        
        self.logUser()
        
        prepareViews(applicationType: checkApplicationState())
        if let sectionName = defaults.string(forKey: "sectionName") {
            prepareDB(withSectionName: sectionName)
            setupConnection(withSectionName: sectionName)
        } else {
            prepareDB()
            setupConnection()
        }
    }
    
    
    func prepareViews(applicationType: ApplicationType) {
        window = UIWindow(frame:UIScreen.main.bounds)
        
        var rootVC: NavigationDrawerController?
        
        switch applicationType {
        case .placeTerminal:
          
            rootVC = prepareTerminalUI()
            break
        case .placeGroup:
            //initStateMachine(applicaitonState: applicationType)
            rootVC = prepareGroupUI()
            prepareBeaconManager()
            break
        case .objectGroup:
            //initStateMachine(applicaitonState: applicationType)
            rootVC = prepareGroupUI(withToolMenuTypes: ToolMenuType.allTypes)
            break
        default:
            //login
            //initStateMachine(applicaitonState: applicationType)
            rootVC = prepareLoginUI()
        }
        
        // Configure the window with the SideNavigationController as the root view controller
        
        if let rnc = window?.rootViewController?.navigationController {
            rnc.pushViewController(rootVC!, animated: true)
        } else {
            window?.rootViewController = rootVC
        }
        
        window?.makeKeyAndVisible()
    }
    
    func prepareBeaconManager() {
        beaconNotificationsManager = BeaconNotificationsManager()
        
        for (index, beaconId) in beaconIds.enumerated() {
            beaconNotificationsManager?.enableNotificationsForBeaconID(beaconId,
                                                                       enterMessage: "enter species \(index)",
                                                                       exitMessage: "exit species \(index)"
            )
        }
    }
    
    func prepareLoginUI() -> NavigationDrawerController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let defaultViewController = storyboard.instantiateViewController(withIdentifier: "defaultViewController") as! DefaultViewController
        
        let sideViewController = storyboard.instantiateViewController(withIdentifier: "sideViewController") as! SideViewController
        
        let navigationController: AppNavigationController = AppNavigationController(rootViewController: defaultViewController)
        
        let navigationDrawerController = NavigationDrawerController(rootViewController: navigationController, leftViewController:sideViewController)
        
        navigationController.isNavigationBarHidden = true
        
        navigationController.statusBarStyle = .lightContent
        
        return navigationDrawerController
    }
    
    func prepareGroupUI(withToolMenuTypes toolMenuTypes: [ToolMenuType] = ToolMenuType.defaultTypes) -> NavigationDrawerController{
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainContainerController = mainStoryboard.instantiateViewController(withIdentifier: "mainContainerController") as! MainContainerController
        
        let sideViewController = mainStoryboard.instantiateViewController(withIdentifier: "sideViewController") as! SideViewController
        
        let navigationController: AppNavigationController = AppNavigationController(rootViewController: mainContainerController)
        
        mainContainerController.toolMenuTypes = toolMenuTypes
        switch checkApplicationState() {
        case .objectGroup:
            mainContainerController.needsTerminal = true
        default:
            mainContainerController.needsTerminal = false
        }
        //menu
        
        let toolMenuController = ToolMenuController(rootViewController: navigationController)
        
        let navigationDrawerController = NavigationDrawerController(rootViewController: toolMenuController, leftViewController:sideViewController)
        
        navigationController.isNavigationBarHidden = true
        navigationController.statusBarStyle = .lightContent
        
    
        
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
        
        return navigationDrawerController
    }
    
    
    func prepareDB(withSectionName sectionName: String = "default") {
        
        let defaults = UserDefaults.standard
        
        switch checkApplicationState() {
        case .placeGroup:
            
            
            setDefaultRealm(withSectionName: sectionName)
            
            checkInitialization()

            
            let hasInit = defaults.bool(forKey: "init")
            
            if !hasInit {
                realmDataController.deleteAllConfigurationAndGroups()
                realmDataController.deleteAllUserData()
                _ = realmDataController.parseNutellaConfigurationJson()
                _ = realmDataController.parseUserGroupConfigurationJson(withSimConfig: (realmDataController.parseSimulationConfigurationJson()), withPlaceHolders: true, withSectionName: sectionName)
                defaults.set(true, forKey: "init")
            }
            
            let groupIndex = defaults.integer(forKey: "groupIndex")
            realmDataController.updateRuntime(withSectionName: sectionName, withSpeciesIndex: nil, withGroupIndex: groupIndex)
            break
        case .placeTerminal:
            
            setTerminalRealm(withSectionName: sectionName)
            
            realmDataController.deleteAllConfigurationAndGroups(withRealmType: RealmType.terminalDB)
            //re-up
            
            _ = realmDataController.parseUserGroupConfigurationJson(withSimConfig: realmDataController.parseSimulationConfigurationJson(withRealmType: RealmType.terminalDB), withPlaceHolders: false, withSectionName: sectionName, withRealmType: RealmType.terminalDB)
            
            let speciesIndex = defaults.integer(forKey: "speciesIndex")
            
            realmDataController.updateRuntime(withSectionName: sectionName, withSpeciesIndex: speciesIndex, withGroupIndex: nil, withRealmType: RealmType.terminalDB)
            break
        case .objectGroup:
            
            setDefaultRealm(withSectionName: sectionName)

            checkInitialization()
            
            let groupIndex = defaults.integer(forKey: "groupIndex")
            realmDataController.updateRuntime(withSectionName: sectionName, withSpeciesIndex: nil, withGroupIndex: groupIndex)
            
            setTerminalRealm(withSectionName: sectionName)
            
            realmDataController.deleteAllConfigurationAndGroups(withRealmType: RealmType.terminalDB)
            //re-up
            
            _ = realmDataController.parseUserGroupConfigurationJson(withSimConfig: realmDataController.parseSimulationConfigurationJson(withRealmType: RealmType.terminalDB), withPlaceHolders: false, withSectionName: sectionName, withRealmType: RealmType.terminalDB)
            
            //let speciesIndex = defaults.integer(forKey: "speciesIndex")
            
            realmDataController.updateRuntime(withSectionName: sectionName, withGroupIndex: nil, withRealmType: RealmType.terminalDB)
        default:
            break
        }
    }
    
    func checkInitialization() {
        let sectionName = defaults.string(forKey: "sectionName")
        let hasInit = defaults.bool(forKey: "init")
        
        if !hasInit {
            realmDataController.deleteAllConfigurationAndGroups()
            realmDataController.deleteAllUserData()
            _ = realmDataController.parseNutellaConfigurationJson()
            _ = realmDataController.parseUserGroupConfigurationJson(withSimConfig: (realmDataController.parseSimulationConfigurationJson()), withPlaceHolders: true, withSectionName: sectionName!)
            defaults.set(true, forKey: "init")
        }
    }
    
    func setDefaultRealm(withSectionName sectionName: String = "default") {
        
        if Platform.isSimulator {
            let testRealmURL = URL(fileURLWithPath: "/Users/aperritano/Desktop/Realm/BeaconTerminal\(sectionName).realm")
            try! realm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
        } else {
            
            var config = Realm.Configuration()
            
            // Use the default directory, but replace the filename with the username
            config.fileURL = config.fileURL!.deletingLastPathComponent()
                .appendingPathComponent("\(sectionName).realm")
            
            // Set this as the configuration used for the default Realm
            Realm.Configuration.defaultConfiguration = config
            
            try! realm = Realm(configuration: Realm.Configuration.defaultConfiguration)
            
            LOG.debug("REALM FILE: \(Realm.Configuration.defaultConfiguration.fileURL)")
        }
    }
    
    func setTerminalRealm(withSectionName sectionName: String = "default") {
        
        let dbName = "\(sectionName)-TERMINAL"
        
        if Platform.isSimulator {
            let testRealmURL = URL(fileURLWithPath: "/Users/aperritano/Desktop/Realm/BeaconTerminal\(dbName).realm")
            try! terminalRealm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
        } else {
            
            var config = Realm.Configuration()
            
            // Use the default directory, but replace the filename with the username
            config.fileURL = config.fileURL!.deletingLastPathComponent()
                .appendingPathComponent("\(dbName).realm")
            
            // Set this as the configuration used for the default Realm
            //Realm.Configuration.defaultConfiguration = config
            
            try! terminalRealm = Realm(configuration: config)
            
            LOG.debug("TerminalRealm FILE: \(config.fileURL)")
        }
    }
    
    func resetDB(withGroupIndex groupIndex: Int = 0) {
        //check nutella connection
        
        //handle_requests: reset
        if let nutella = nutella {
            
            let block = DispatchWorkItem {
                var dict = [String: Int]()
                
                dict["groupIndex"] = groupIndex
                let json = JSON(dict)
                let jsonObject: Any = json.object
                nutella.net.asyncRequest("all_notes_with_group", message: jsonObject as AnyObject, requestName: "all_notes_with_group")
            }
            DispatchQueue.main.async(execute: block)
        } else {
            //we have been disconnected
        }
    }
    
    
    // Mark: Nutella setup
    
    func setupConnection(withSectionName sectionName: String = "default") {
        
        
        
        switch self.checkApplicationState() {
        case .placeGroup, .objectGroup:
            nutella = Nutella(brokerHostname: CURRENT_HOST,
                              appId: "wallcology",
                              runId: sectionName,
                              componentId: ApplicationType.placeGroup.rawValue, netDelegate: self)
            break
        case .placeTerminal:
            nutella = Nutella(brokerHostname: CURRENT_HOST,
                              appId: "wallcology",
                              runId: sectionName,
                              componentId: ApplicationType.placeTerminal.rawValue, netDelegate: self)
        default:
            break
        }
        
        
        
        
        
        let sub_1 = "note_changes"
        let sub_2 = "echo_out"
        let sub_3 = "place_changes"
        
        // let sub_3 = "set_current_run"
        nutella?.net.subscribe(sub_1)
        nutella?.net.subscribe(sub_2)
        
        var dict = [String:String]()
        dict["HEY_NOW_MAN"] = "HELLO"
        
        //nutella?.net.publish("echo_in", message: dict as AnyObject)
        //nutella?.net.subscribe(sub_3)
        Util.makeToast("Subscribed to \(sub_1):\(sub_2)")
        
        switch checkApplicationState() {
        case .placeGroup, .objectGroup:
            //realmDataController.queryNutellaAllNotes(withType: "group")
            break
        case .placeTerminal:
            realmDataController.queryNutellaAllNotes(withType: "species", withRealmType: RealmType.terminalDB)
        default:
            break
        }
        
        //resetDB()
    }
    
    // Mark: StateMachine
    
    func initStateMachine(applicaitonState: ApplicationType) {
        
        applicationStateMachine.addEvents([placeTerminalEvent, placeGroupEvent, objectGroupEvent])
        
        placeTerminalState.didEnterState = { state in self.preparePlaceTerminal() }
        placeGroupState.didEnterState = { state in self.preparePlaceGroup() }
        objectGroupState.didEnterState = { state in self.prepareObjectGroup() }
        
        switch applicaitonState {
        case .placeGroup:
            if !applicationStateMachine.fireEvent(placeGroupEvent).successful {
                //LOG.debug("We didn't transition")
            }
        case .objectGroup:
            if !applicationStateMachine.fireEvent(objectGroupEvent).successful {
                //LOG.debug("We didn't transition")
            }
        case .placeTerminal:
            if !applicationStateMachine.fireEvent(placeTerminalEvent).successful {
                //LOG.debug("We didn't transition")
            }
            
        default:
            if !applicationStateMachine.fireEvent(objectGroupEvent).successful {
                //LOG.debug("We didn't transition")
            }
        }
    }
    
    func changeSystemStateTo(_ state: ApplicationType) {
        switch state {
        case .placeGroup:
            if !applicationStateMachine.fireEvent(placeGroupEvent).successful {
                //LOG.debug("We didn't transition")
            }
        case .placeTerminal:
            if !applicationStateMachine.fireEvent(placeTerminalEvent).successful {
                //LOG.debug("We didn't transition")
            }
        case .objectGroup:
            if !applicationStateMachine.fireEvent(objectGroupEvent).successful {
                //LOG.debug("We didn't transition")
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
    
    func checkCurrentRun(run:String) {
        
    }
}

extension AppDelegate: NutellaNetDelegate {
    
    func requestReceived(_ channel: String, request: Any?, from: [String : String]) -> AnyObject? {
        LOG.debug("----- Request Recieved Returning nil -----")
        return nil
    }
    
    func responseReceived(_ channel: String, requestName: String?, response: Any, from: [String : String]) {
        var nutellaUpdate = NutellaUpdate()
        nutellaUpdate.channel = channel
        nutellaUpdate.message = response
        nutellaUpdate.updateType = .response
        realmDataController.processNutellaUpdate(nutellaUpdate: nutellaUpdate)
        LOG.debug("----- Response Recieved on: \(channel) from: \(from) -----")
    }
    
    func messageReceived(_ channel: String, message: Any, from: [String : String]) {
        var nutellaUpdate = NutellaUpdate()
        nutellaUpdate.channel = channel
        nutellaUpdate.message = message
        nutellaUpdate.updateType = .message
        realmDataController.processNutellaUpdate(nutellaUpdate: nutellaUpdate)
        LOG.debug("----- PubSub Recieved on: \(channel) from: \(from) with: \(message)-----")
        //once recieved set_run runid
        //check run, async 'get_current_run"
        //if cool, request 'roster', give portal types 'group', get list of groups,
        //get species names - terminal 
    }
    
}

