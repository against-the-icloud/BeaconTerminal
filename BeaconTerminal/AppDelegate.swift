import UIKit
import RealmSwift
import Material
import XCGLogger
import Nutella
import Transporter
import Alamofire
import NVActivityIndicatorView


let DEBUG = true
let REFRESH_DB = true
let EXPORT_DB = true

// localhost || remote
let HOST = "local"
let REMOTE = "ltg.evl.uic.edu"
let LOCAL = "127.0.0.1"
let LOCAL_IP = "10.0.1.6"
//let LOCAL_IP = "131.193.79.203"
var CURRENT_HOST = LOCAL_IP
var SECTION_NAME = "default"

let ESTIMOTE_ID = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"

let LOG: XCGLogger = {
    
    // Setup XCGLogger
    let LOG = XCGLogger.default
    //LOG. = true // Or set the XcodeColors environment variable in your scheme to YES
    //    LOG.xcodeColors = [
    //        .verbose: .lightGrey,
    //        .debug: .red,
    //        .info: .darkGreen,
    //        .warning: .orange,
    //        .error: XCGLogger.XcodeColor(fg: UIColor.red, bg: UIColor.white()), // Optionally use a UIColor
    //        .severe: XCGLogger.XcodeColor(fg: (255, 255, 255), bg: (255, 0, 0)) // Optionally use RGB values directly
    //    ]
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
    case cloudGroup = "CLOUD GROUP"
    
    static let allValues = [placeTerminal, placeGroup, objectGroup, cloudGroup]
}

enum LoginTypes: String {
    case autoLogin = "autoLogin"
    case currentRun = "currentRun"
    case currentSection = "currentSection"
    case currentRoster = "currentRoster"
    case currentGroupChannels = "currentGroupChannels"
    case currentSpeciesNames = "currentSpeciesNames"
    
    static let allValues = [currentRun, currentSection, currentRoster, currentGroupChannels, currentSpeciesNames]
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
let cloudGroupState = State(ApplicationType.cloudGroup)
let loginState = State(ApplicationType.login)
let applicationStateMachine = StateMachine(initialState: loginState, states: [placeGroupState, objectGroupState, cloudGroupState, placeTerminalState])
//init events

let loginEvent = Event(name: "login", sourceValues: [ApplicationType.login, ApplicationType.objectGroup, ApplicationType.placeGroup, ApplicationType.cloudGroup],
                       destinationValue: ApplicationType.login)

let placeTerminalEvent = Event(name: "placeTerminal", sourceValues: [ApplicationType.login, ApplicationType.objectGroup, ApplicationType.placeGroup, ApplicationType.cloudGroup],
                               destinationValue: ApplicationType.placeTerminal)

let placeGroupEvent = Event(name: "placeGroup", sourceValues: [ApplicationType.login,ApplicationType.objectGroup, ApplicationType.placeTerminal, ApplicationType.cloudGroup], destinationValue: ApplicationType.placeGroup)
let objectGroupEvent = Event(name: "objectGroup", sourceValues: [ApplicationType.login, ApplicationType.placeGroup, ApplicationType.placeTerminal, ApplicationType.cloudGroup], destinationValue: ApplicationType.objectGroup)

let cloudGroupEvent = Event(name: "cloudGroup", sourceValues: [ApplicationType.login, ApplicationType.placeGroup, ApplicationType.objectGroup, ApplicationType.placeTerminal], destinationValue: ApplicationType.cloudGroup)


//login state machine
let autoLoginState = State(LoginTypes.autoLogin)
let autoLoginEvent = Event(name: "autoLogin", sourceValues: [LoginTypes.autoLogin], destinationValue: LoginTypes.autoLogin)
let currentSectionState = State(LoginTypes.currentSection)
let currentSectionEvent = Event(name: "currentSection", sourceValues: [LoginTypes.autoLogin], destinationValue: LoginTypes.currentSection)

let currentRosterState = State(LoginTypes.currentRoster)
let currentRosterEvent = Event(name: "currentRoster", sourceValues: [LoginTypes.currentSection], destinationValue: LoginTypes.currentRoster)


let loginStateMachine = StateMachine(initialState: autoLoginState, states: [autoLoginState, currentSectionState,currentRosterState])


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
    case speciesNames = "get_species_names"
    case getCurrentRun = "get_current_run"
    case getRoster = "roster"
}

enum NutellaQueryType: String {
    case species = "species"
    case group = "group"
    case currentRun = "currentRun"
    case currentRoster = "currentRoster"
    case currentChannelList = "currentChannelList"
    case speciesNames = "speciesNames"
}


struct NutellaUpdate {
    var channel: String?
    var message: Any?
    var updateType:  NutellaMessageType?
    var response: Any?
}


var beaconNotificationsManager: BeaconNotificationsManager?

let beaconIds = [BeaconID(identifier: "19450ac90c94be0b7d66c0e9f654d333", major: 1, minor: 1),
                 BeaconID(identifier: "ee3a94ba9ed4a25cffaf290226c6d22c", major: 1, minor: 2),
                 BeaconID(identifier: "7148d3b4f6b3d192f52c3936fb9bcd33", major: 1, minor: 3),
                 BeaconID(identifier: "040d277eac74d336847970113ccbe739", major: 1, minor: 4),
                 BeaconID(identifier: "9e21d6e5190efbe7554742d62c1f1f0a", major: 1, minor: 5),
                 BeaconID(identifier: "581736ca8b0332c774b07edc687f8231", major: 1, minor: 6),
                 BeaconID(identifier: "5edb82480cbba797722765f64430b71f", major: 1, minor: 7),
                 BeaconID(identifier: "38258bb861c5fe5011d0752ab0b82000", major: 1, minor: 8),
                 BeaconID(identifier: "3725c7b4dd3a7dd2345f5d83488ac419", major: 1, minor: 9),
                 BeaconID(identifier: "fd89d7d2ad4138ed782b965bf2380527", major: 1, minor: 10),
                 BeaconID(identifier: "f90c0feb677f03759c6afce57048cc0f", major: 1, minor: 11),
                 BeaconID(identifier: "040d277eac74d336847970113ccbe739", major: 1, minor: 12)]


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
    
    var window: UIWindow?
    
    //delegates
    weak var controlPanelDelegate: ControlPanelDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        //setupLoginConnection()
        
        setupHockeyApp()
        
        ESTConfig.setupAppID("wallcology-2016-emb", andAppToken: "fd9eb675b3f09982fd5c1788f7a437dd")
        //crash analytics
        //Fabric.with([Crashlytics.self])
        
        
        
        realmDataController = RealmDataController()
        
        prepareThemes()
        
        manualLogin()
        
        return true
    }
    
    func manualLogin() {
        let groupNames = ["Team 1","Team 2", "Team 3","Team 4","Team 5"]
        let sectionNames = ["default","guest","6BM","6MT","6ADF"]
        
        UserDefaults.standard.set(false, forKey: "init")
        UserDefaults.standard.set(sectionNames, forKey: "sectionNames")
        UserDefaults.standard.set(groupNames, forKey: "currentRoster")
        UserDefaults.standard.synchronize()
        
        initStateMachine(applicaitonState: .login)
        
        prepareLoginInterface(isRemote: false)
    }
    
    func autoLogin() {
        initLoginStateMachine(loginState: .autoLogin)
        getAppDelegate().changeLoginStateTo(.autoLogin)
        
    }
    
    func prepareThemes() {
        UIView.hr_setToastThemeColor(#colorLiteral(red: 0.9022639394, green: 0.9022851586, blue: 0.9022737145, alpha: 1))
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert], categories: nil))
        
    }
    
    func setupHockeyApp() {
        BITHockeyManager.shared().configure(withIdentifier: "dc4ac5b3c9af4127a03dc23bbf3b800f")
        // Do some additional configuration if needed here
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
    }
    
    func shortCircuitLogin() {
        
        getAppDelegate().changeSystemStateTo(.objectGroup)
        
        let defaults = UserDefaults.standard
        defaults.set(2, forKey: "condition")
        defaults.set("default", forKey: "sectionName")
        defaults.set(0, forKey: "speciesIndex")
        //defaults.set(0, forKey: "groupIndex")
        defaults.synchronize()
        
        // TODO: Move this to where you establish a user session
        
        
        loadCondition()
    }
    
    //    func logUser() {
    //        // TODO: Use the current user's information
    //        // You can call any combination of these three methods
    //        let defaults = UserDefaults.standard
    ////        defaults.set(2, forKey: "condition")
    ////        defaults.set("default", forKey: "sectionName")
    ////        defaults.set(0, forKey: "groupIndex")
    ////
    //        if let groupIndex = defaults.value(forKey: "groupIndex") as? Int {
    //            Crashlytics.sharedInstance().setIntValue(Int32(groupIndex), forKey: "groupIndex")
    //        }
    //
    //        if let speciesIndex = defaults.value(forKey: "speciesIndex") as? Int {
    //            Crashlytics.sharedInstance().setIntValue(Int32(speciesIndex), forKey: "speciesIndex")
    //        }
    //
    //        if let condition = defaults.value(forKey: "condition") as? Int {
    //            Crashlytics.sharedInstance().setIntValue(Int32(condition), forKey: "condition")
    //        }
    //
    //        if let sectionName = defaults.value(forKey: "sectionName"){
    //            Crashlytics.sharedInstance().setObjectValue(sectionName, forKey: "sectionName")
    //        }
    //    }
    
    
    // Mark: View setup
    
    // Mark: db setup
    
    func loadCondition() {
        
        //self.logUser()
        
        let appState = checkApplicationState()
        
        prepareViews(applicationType: appState)
        postInitialization(applicationType: appState)
    }
    
    func preInitialization(applicationType: ApplicationType) {
        if let sectionName = UserDefaults.standard.string(forKey: "sectionName") {
            switch applicationType {
            case .placeTerminal, .placeGroup, .objectGroup, .cloudGroup:
                setupConnection(withSectionName: sectionName)
            default: break
            }
        }
    }
    
    func prepareViews(applicationType: ApplicationType) {
        window = UIWindow(frame:UIScreen.main.bounds)
        
        var rootVC: NavigationDrawerController?
        
        preInitialization(applicationType: applicationType)
        
        switch applicationType {
        case .placeTerminal:
            rootVC = prepareTerminalUI()
        case .placeGroup:
            rootVC = prepareGroupUI()
            prepareBeaconManager()
        case .objectGroup:
            rootVC = prepareGroupUI(withToolMenuTypes: ToolMenuType.allTypes)
        case .cloudGroup:
            rootVC = prepareGroupUI(withToolMenuTypes: ToolMenuType.cloudTypes)
        default:
            break
        }
        
        // Configure the window with the SideNavigationController as the root view controller
        
        if let rnc = window?.rootViewController?.navigationController {
            rnc.pushViewController(rootVC!, animated: true)
        } else {
            window?.rootViewController = rootVC
        }
        
        window?.makeKeyAndVisible()
    }
    
    func postInitialization(applicationType: ApplicationType) {
        if let sectionName = UserDefaults.standard.string(forKey: "sectionName") {
            switch applicationType {
            case .placeGroup, .objectGroup, .cloudGroup:
                prepareDB(withSectionName: sectionName)                
                realmDataController.queryNutella(withType: .speciesNames)
            case .placeTerminal:
                prepareDB(withSectionName: sectionName)
                realmDataController.queryNutellaAllNotes(withType: .species, withRealmType: RealmType.terminalDB)
            default: break
            }
        }
    }
    
    func prepareLoginInterface(isRemote: Bool) {
        switch isRemote {
        case true:
            break
        default:
            window = UIWindow(frame:UIScreen.main.bounds)
            
            var rootVC: NavigationDrawerController?
            rootVC = prepareLoginUI(shouldShowLogin: false)
            if let rnc = window?.rootViewController?.navigationController {
                rnc.pushViewController(rootVC!, animated: true)
            } else {
                window?.rootViewController = rootVC
            }
            
            window?.makeKeyAndVisible()
        }
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
    
    
    func prepareAutoLoginUI() -> DefaultViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let defaultViewController = storyboard.instantiateViewController(withIdentifier: "defaultViewController") as! DefaultViewController
        
        defaultViewController.shouldShowLogin = false
        
        return defaultViewController
    }
    
    func prepareLoginUI(shouldShowLogin: Bool = true) -> NavigationDrawerController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let defaultViewController = storyboard.instantiateViewController(withIdentifier: "defaultViewController") as! DefaultViewController
        
        defaultViewController.shouldShowLogin = true
        
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
        case .objectGroup, .cloudGroup:
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
        navigationController.statusBarStyle = .lightContent
        
        return navigationDrawerController
    }
    
    
    func prepareDB(withSectionName sectionName: String = "default") {
        
        let defaults = UserDefaults.standard
        
        switch checkApplicationState() {
        case .placeGroup:
            
            
            setDefaultRealm(withSectionName: sectionName)
            
            checkInitialization()
            
            
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
        case .objectGroup, .cloudGroup:
            
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
        if let sectionName = UserDefaults.standard.string(forKey: "sectionName")  {
            _ = UserDefaults.standard.bool(forKey: "init")
            
            
            let r = realmDataController.getRealm()
            let allSos =  r.allSpeciesObservations()
            if allSos.isEmpty {
                //_ = realmDataController.parseNutellaConfigurationJson()
                _ = realmDataController.parseUserGroupConfigurationJson(withSimConfig: (realmDataController.parseSimulationConfigurationJson()), withPlaceHolders: true, withSectionName: sectionName)
                UserDefaults.standard.set(true, forKey: "init")
                UserDefaults.standard.synchronize()
            }
        }
        
        //        if !hasInit {
        //            realmDataController.deleteAllConfigurationAndGroups()
        //            realmDataController.deleteAllUserData()
        //            _ = realmDataController.parseNutellaConfigurationJson()
        //            _ = realmDataController.parseUserGroupConfigurationJson(withSimConfig: (realmDataController.parseSimulationConfigurationJson()), withPlaceHolders: true, withSectionName: sectionName!)
        //            defaults.set(true, forKey: "init")
        //        }
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
        
        
        realmDataController.queryNutellaAllNotes(withType: .group)
        
    }
    
    
    // Mark: Nutella setup
    
    func setupConnection(withSectionName sectionName: String = "default") {
        
        nutella = Nutella(brokerHostname: CURRENT_HOST,
                          appId: "wallcology",
                          runId: sectionName,
                          componentId: "", netDelegate: self)
        
        
        
        let sub_1 = "note_changes"
        _ = "echo_out"
        //let sub_3 = "place_changes"
        
        nutella?.net.subscribe(sub_1)
        
        // let sub_3 = "set_current_run"
        //nutella?.net.subscribe(sub_1)
        //var dict = [String:String]()
        //dict["HEY_NOW_MAN"] = "HELLO"
        
        //nutella?.net.publish("echo_in", message: dict as AnyObject)
        //nutella?.net.subscribe(sub_3)
        
        
        
        
        //resetDB()
    }
    
    // Mark: Nutella LOGIN
    
    func setupLoginConnection() {
        
        let currentState = checkLoginState()
        
        switch currentState {
        case .currentRun:
            nutella = Nutella(brokerHostname: CURRENT_HOST,
                              appId: "wallcology",
                              runId: "default",
                              componentId: "", netDelegate: self)
            
        default:
            nutella = Nutella(brokerHostname: CURRENT_HOST,
                              appId: "wallcology",
                              runId: "default",
                              componentId: "login", netDelegate: self)
        }
        
        switch currentState {
        case .autoLogin:
            realmDataController.queryNutella(withType: .currentRun)
        default:
            break
        }
    }
    
    // Mark: LoginStateMachine
    
    var loginViewController: DefaultViewController?
    
    func initLoginStateMachine(loginState: LoginTypes) {
        loginStateMachine.addEvents([autoLoginEvent, currentSectionEvent,currentRosterEvent])
        
        autoLoginState.didEnterState = { state in
            self.window = UIWindow(frame:UIScreen.main.bounds)
            
            self.loginViewController = self.prepareAutoLoginUI()
            self.window?.rootViewController = self.loginViewController
            self.window?.makeKeyAndVisible()
            
            
            self.loginViewController?.startAnimating(CGSize(width: 100, height: 100), message: "Fetching Current Run...")
            
            //defualt connection
            self.setupLoginConnection()
        }
        
        
        currentSectionState.didEnterState = { state in
            if let sectionName = UserDefaults.standard.string(forKey: "sectionName") {
                self.setupConnection(withSectionName: sectionName)
                realmDataController.queryNutella(withType: .speciesNames)
                realmDataController.queryNutella(withType: .currentRoster)
                realmDataController.queryNutella(withType: .currentChannelList)
            }
            
        }
        
        currentRosterState.didEnterState = { state in
//            if let sectionName = UserDefaults.standard.string(forKey: "sectionName") {
//                //self.setupConnection(withSectionName: sectionName)
//                
//            }
            
        }
        
    }
    
    func changeLoginStateTo(_ state: LoginTypes) {
        switch state {
        case .autoLogin:
            if loginStateMachine.fireEvent(autoLoginEvent).successful {
                
            }
        case .currentSection:
            if loginStateMachine.fireEvent(currentSectionEvent).successful {
                
            }
        case .currentRoster:
            if loginStateMachine.fireEvent(currentRosterEvent).successful {
                
            }
        default:
            break
        }
    }
    
    func checkLoginState() -> LoginTypes {
        return loginStateMachine.currentState.value
    }
    
    // Mark: StateMachine
    
    func initStateMachine(applicaitonState: ApplicationType) {
        
        applicationStateMachine.addEvents([placeTerminalEvent, placeGroupEvent, objectGroupEvent, cloudGroupEvent, loginEvent])
        
        placeTerminalState.didEnterState = { state in self.preparePlaceTerminal() }
        placeGroupState.didEnterState = { state in self.preparePlaceGroup() }
        objectGroupState.didEnterState = { state in self.prepareObjectGroup() }
        cloudGroupState.didEnterState = { state in self.prepareCloudGroup() }
        loginState.didEnterState = { state in self.prepareLogin() }
        
        
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
        case .cloudGroup:
            if !applicationStateMachine.fireEvent(cloudGroupEvent).successful {
                //LOG.debug("We didn't transition")
            }
        default:
            if !applicationStateMachine.fireEvent(loginEvent).successful {
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
        case .cloudGroup:
            if !applicationStateMachine.fireEvent(cloudGroupEvent).successful {
                //LOG.debug("We didn't transition")
            }
        default:
            if !applicationStateMachine.fireEvent(loginEvent).successful {
                //LOG.debug("We didn't transition")
            }
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
    
    func prepareCloudGroup() {
        
    }
    
    func prepareLogin() {
        
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
        LOG.debug("\n\n----- Response Recieved on: \(channel) from: \(from) -----\n\n")
        LOG.debug("----- Response \(response)")
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

