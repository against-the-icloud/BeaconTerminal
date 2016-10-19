import UIKit
import RealmSwift
import Material
import XCGLogger
import Nutella
import Transporter
import Alamofire
import NVActivityIndicatorView
import AVFoundation

let DEBUG = true
let REFRESH_DB = true
let EXPORT_DB = true
var needsTerminal = false
// localhost || remote
let HOST = "local"
let REMOTE = "ltg.evl.uic.edu"
let LOCAL = "127.0.0.1"
let LOCAL_IP = "10.0.1.6"
//let LOCAL_IP = "131.193.79.203"
var CURRENT_HOST = REMOTE
var SECTION_NAME = "default"

let ESTIMOTE_ID = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"

let LOG: XCGLogger = {
    // Setup XCGLogger
    let LOG = XCGLogger.default
    return LOG
}()

//MARK: State Machine

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
    case ready = "READY"
    
    static let allValues = [placeTerminal, placeGroup, objectGroup, cloudGroup]
    static let allGroups = [placeGroup, objectGroup, cloudGroup]

}

enum LoginTypes: String {
    case startLogin = "startLogin"
    case autoLogin = "autoLogin"
    case manualLogin = "manualLogin"
    case currentRun = "currentRun"
    case currentSection = "currentSection"
    case currentRoster = "currentRoster"
    case currentChannelNames = "currentChannelNames"
    case currentChannelList = "currentChannelList"
    case currentActivityAndRoom = "currentActivityAndRoom"
    case currentSpeciesNames = "currentSpeciesNames"
    
    static let allValues = [autoLogin, manualLogin, currentRun, currentSection, currentRoster, currentChannelList, currentSpeciesNames, currentActivityAndRoom, currentChannelNames]
}

enum Sound {
    case coin
    case tap
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
let readyState = State(ApplicationType.ready)

var applicationStateMachine: StateMachine<ApplicationType>?
//init events

let loginEvent = Event(name: "login", sourceValues: [ApplicationType.login, ApplicationType.objectGroup, ApplicationType.placeGroup, ApplicationType.cloudGroup],
                       destinationValue: ApplicationType.login)

let placeTerminalEvent = Event(name: "placeTerminal", sourceValues: [ApplicationType.ready,ApplicationType.login, ApplicationType.placeGroup, ApplicationType.objectGroup, ApplicationType.placeTerminal],
                               destinationValue: ApplicationType.placeTerminal)

let placeGroupEvent = Event(name: "placeGroup", sourceValues: [ApplicationType.ready,ApplicationType.login, ApplicationType.placeGroup, ApplicationType.objectGroup, ApplicationType.placeTerminal], destinationValue: ApplicationType.placeGroup)
let objectGroupEvent = Event(name: "objectGroup", sourceValues: [ApplicationType.ready,ApplicationType.login, ApplicationType.placeGroup, ApplicationType.objectGroup, ApplicationType.placeTerminal], destinationValue: ApplicationType.objectGroup)

let cloudGroupEvent = Event(name: "cloudGroup", sourceValues: [ApplicationType.ready,ApplicationType.login, ApplicationType.placeGroup, ApplicationType.objectGroup, ApplicationType.placeTerminal], destinationValue: ApplicationType.cloudGroup)

let readyEvent = Event(name: "ready", sourceValues: [ApplicationType.ready,ApplicationType.login,ApplicationType.objectGroup, ApplicationType.placeGroup, ApplicationType.cloudGroup], destinationValue: ApplicationType.ready)

//login state machine
let startLoginState = State(LoginTypes.startLogin)
let startLoginEvent = Event(name: "startLogin", sourceValues: [LoginTypes.startLogin], destinationValue: LoginTypes.startLogin)


let autoLoginState = State(LoginTypes.autoLogin)
let autoLoginEvent = Event(name: "autoLogin", sourceValues: [LoginTypes.startLogin, LoginTypes.manualLogin], destinationValue: LoginTypes.autoLogin)

let manualLoginState = State(LoginTypes.manualLogin)
let manualLoginEvent = Event(name: "manualLogin", sourceValues: [LoginTypes.startLogin], destinationValue: LoginTypes.manualLogin)

let currentSectionState = State(LoginTypes.currentSection)
let currentSectionEvent = Event(name: "currentSection", sourceValues: [LoginTypes.autoLogin], destinationValue: LoginTypes.currentSection)

let currentRosterState = State(LoginTypes.currentRoster)
let currentRosterEvent = Event(name: "currentRoster", sourceValues: [LoginTypes.currentSection], destinationValue: LoginTypes.currentRoster)


//Run
let currentActivityAndRunState = State(LoginTypes.currentActivityAndRoom)
let currentActivityAndRunEvent = Event(name: "currentActivityAndRun", sourceValues: [LoginTypes.currentRoster, LoginTypes.manualLogin], destinationValue: LoginTypes.currentActivityAndRoom)

let currentChannelNamesState = State(LoginTypes.currentChannelNames)
let currentChannelNamesEvent = Event(name: "currentChannelNames", sourceValues: [LoginTypes.currentChannelList], destinationValue: LoginTypes.currentChannelNames)

let currentChannelListState = State(LoginTypes.currentChannelList)
let currentChannelListEvent = Event(name: "currentChannelList", sourceValues: [LoginTypes.currentActivityAndRoom], destinationValue: LoginTypes.currentChannelList)


var loginStateMachine: StateMachine<LoginTypes>?


var realmDataController : RealmDataController = RealmDataController()

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
}


//MARK: Nutella supports

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
    case currentActivityAndRoom = "currentActivityAndRoom"
    case channelList = "channel_list"
    case channelNames = "channel_names"
}

enum NutellaQueryType: String {
    case species = "species"
    case group = "group"
    case currentRun = "currentRun"
    case currentRoster = "currentRoster"
    case currentChannelList = "currentChannelList"
    case currentChannelNames = "currentChannelNames"
    case currentActivityAndRoom = "currentActivityAndRoom"
    case speciesNames = "speciesNames"
}


struct NutellaUpdate {
    var channel: String?
    var message: Any?
    var updateType:  NutellaMessageType?
    var response: Any?
}


let beaconIds = [BeaconID(identifier: "19450ac90c94be0b7d66c0e9f654d333", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D",  major: 111, minor: 1, withSpeciesIndex: 0),
                 BeaconID(identifier: "ee3a94ba9ed4a25cffaf290226c6d22c", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 1, minor: 2,withSpeciesIndex: 1),
                 BeaconID(identifier: "7148d3b4f6b3d192f52c3936fb9bcd33", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 1, minor: 3,withSpeciesIndex: 2),
                 BeaconID(identifier: "040d277eac74d336847970113ccbe739", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 1, minor: 4,withSpeciesIndex: 3),
                 BeaconID(identifier: "9e21d6e5190efbe7554742d62c1f1f0a", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 1, minor: 5,withSpeciesIndex: 4),
                 BeaconID(identifier: "581736ca8b0332c774b07edc687f8231", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 1, minor: 6,withSpeciesIndex: 5),
                 BeaconID(identifier: "5edb82480cbba797722765f64430b71f", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 1, minor: 7,withSpeciesIndex: 6),
                 BeaconID(identifier: "38258bb861c5fe5011d0752ab0b82000", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 1, minor: 8,withSpeciesIndex: 7),
                 BeaconID(identifier: "3725c7b4dd3a7dd2345f5d83488ac419", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 1, minor: 9,withSpeciesIndex: 8),
                 BeaconID(identifier: "fd89d7d2ad4138ed782b965bf2380527", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 1, minor: 10,withSpeciesIndex: 9),
                 BeaconID(identifier: "f90c0feb677f03759c6afce57048cc0f", UUIDString:"B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 1, minor: 11,withSpeciesIndex: 10)]


var estMonitoringManager = ESTMonitoringManager()
var estBeaconManager = ESTBeaconManager()

let beaconNotificationKey = "ltg.evl.uic.edu.beaconNotificationKey"


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
        
        realmDataController = RealmDataController()
        
        prepareThemes()
        
        
        manualLogin()
        
        return true
    }
    
    func manualLogin() {
        initStateMachine()
        initLoginStateMachine()
        realmDataController = RealmDataController()

        prepareLoginInterface(isRemote: false)
    }
    
    func autoLogin() {
        initLoginStateMachine()

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
    
    // MARK: View setup
    
    func loadCondition() {
        
        //self.logUser()
        
        let appState = checkApplicationState()
        
        prepareViews(applicationType: appState)
    }
    
    func prepareViews(applicationType: ApplicationType) {
        window = UIWindow(frame:UIScreen.main.bounds)
        
        var rootVC: NavigationDrawerController?
        
        preInitialization(applicationType: applicationType)
        
        switch applicationType {
        case .placeTerminal:
            needsTerminal = true
            rootVC = prepareTerminalUI()
        case .placeGroup:
            needsTerminal = false
            rootVC = prepareGroupUI()
            prepareBeacons()
        case .objectGroup:
            needsTerminal = true
            rootVC = prepareGroupUI(withToolMenuTypes: ToolMenuType.allTypes)
        case .cloudGroup:
            needsTerminal = true
            rootVC = prepareGroupUI(withToolMenuTypes: ToolMenuType.cloudTypes)
        default:
            break
        }
        
        
        postInitialization(applicationType: applicationType)

        // Configure the window with the SideNavigationController as the root view controller
        
        if let rnc = window?.rootViewController?.navigationController {
            rnc.pushViewController(rootVC!, animated: true)
        } else {
            window?.rootViewController = rootVC
        }
        
        window?.makeKeyAndVisible()
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
    
    func postInitialization(applicationType: ApplicationType) {
        if let sectionName = UserDefaults.standard.string(forKey: "sectionName") {
            switch applicationType {
            case .placeGroup, .objectGroup, .cloudGroup:
                prepareDB(withSectionName: sectionName)                
                realmDataController.queryNutella(withType: .speciesNames)
            case .placeTerminal:
                prepareDB(withSectionName: sectionName)
                realmDataController.queryNutella(withType: .speciesNames)
                realmDataController.queryNutellaAllNotes(withType: .species, withRealmType: RealmType.terminalDB)
            default: break
            }
        }
    }
    
    func prepareLoginInterface(isRemote: Bool) {
            window = UIWindow(frame:UIScreen.main.bounds)
            window?.rootViewController = prepareLoginUI(shouldShowLogin: false)
            window?.makeKeyAndVisible()
    }
    
//    func prepareBeaconManager() {
//        beaconNotificationsManager = BeaconNotificationsManager()
//        for (index, beaconId) in beaconIds.enumerated() {
//            beaconNotificationsManager?.enableNotificationsForBeaconID(beaconId,
//                                                                       enterMessage: "enter species \(index)",
//                exitMessage: "exit species \(index)"
//            )
//        }
//    }
    
    
    func prepareAutoLoginUI() -> DefaultViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let defaultViewController = storyboard.instantiateViewController(withIdentifier: "defaultViewController") as! DefaultViewController
        
        defaultViewController.shouldShowLogin = false
        
        return defaultViewController
    }
    
    func prepareLoginUI(shouldShowLogin: Bool = true) -> NavigationDrawerController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.loginViewController = storyboard.instantiateViewController(withIdentifier: "defaultViewController") as! DefaultViewController
        
        self.loginViewController?.shouldShowLogin = true
        
        let sideViewController = storyboard.instantiateViewController(withIdentifier: "sideViewController") as! SideViewController
        
        let navigationController: AppNavigationController = AppNavigationController(rootViewController: self.loginViewController!)
        
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
            let groupIndex = UserDefaults.standard.integer(forKey: "groupIndex")
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
    
    
    // MARK: Nutella setup
    
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
    
    // MARK: Nutella LOGIN
    
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
    
    // MARK: LoginStateMachine
    
    var loginViewController: DefaultViewController?
    
    func initLoginStateMachine() {
        loginStateMachine = StateMachine(initialState: startLoginState, states: [startLoginState,autoLoginState, manualLoginState, currentSectionState,currentRosterState, currentChannelListState, currentChannelNamesState, currentActivityAndRunState])
        
        loginStateMachine?.addEvents([startLoginEvent, manualLoginEvent, autoLoginEvent, currentSectionEvent,currentRosterEvent, currentChannelListEvent, currentActivityAndRunEvent, currentChannelNamesEvent])
    }
    
    func changeLoginStateTo(_ state: LoginTypes) {
        switch state {
        case .startLogin:
             if (loginStateMachine?.fireEvent(startLoginEvent).successful)! {
                break
            }
        case .manualLogin:
            if (loginStateMachine?.fireEvent(manualLoginEvent).successful)! {
                break
            }
        case .autoLogin:
            if (loginStateMachine?.fireEvent(autoLoginEvent).successful)! {
                //defualt connection
                self.setupLoginConnection()
                
                let ad = ActivityData(size: CGSize.init(width: 100.0, height: 100.0),
                                      message: "Fetching sections, roster...",
                                      displayTimeThreshold: 4,
                                      minimumDisplayTime: 4)
                
                NVActivityIndicatorPresenter.sharedInstance.startAnimating(ad)
                
                
            }
            
        case .currentSection:
            if (loginStateMachine?.fireEvent(currentSectionEvent).successful)! {
                if let sectionName = UserDefaults.standard.string(forKey: "sectionName") {
                    self.setupConnection(withSectionName: sectionName)
                    realmDataController.queryNutella(withType: .currentRoster)

                }
            }
        case .currentRoster:
            if (loginStateMachine?.fireEvent(currentRosterEvent).successful)! {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self.loginViewController?.showGroupLogin(showConditionAfter: true)
            }
        case .currentActivityAndRoom:
            if (loginStateMachine?.fireEvent(currentActivityAndRunEvent).successful)! {
                let ad = ActivityData(size: CGSize.init(width: 100.0, height: 100.0),
                                      message: "Fetching current activity, channel lineup...",
                                      displayTimeThreshold: 4,
                                      minimumDisplayTime: 4)
                
                NVActivityIndicatorPresenter.sharedInstance.startAnimating(ad)
                realmDataController.queryNutella(withType: .currentActivityAndRoom)
                
            }
        case .currentChannelList:
            if (loginStateMachine?.fireEvent(currentChannelListEvent).successful)! {
                realmDataController.queryNutella(withType: .currentChannelList)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }
  
        case .currentChannelNames:
            if (loginStateMachine?.fireEvent(currentChannelNamesEvent).successful)! {
                realmDataController.queryNutella(withType: .currentChannelNames)

            }
        default:
            break
        }
    }
    
    func checkLoginState() -> LoginTypes {
        return loginStateMachine!.currentState.value
    }
    
    // MARK: StateMachine
    
    func initStateMachine() {
        
        applicationStateMachine = StateMachine(initialState: readyState, states: [placeGroupState, objectGroupState, cloudGroupState, placeTerminalState, loginState])
        
        applicationStateMachine?.addEvents([placeTerminalEvent, placeGroupEvent, objectGroupEvent, cloudGroupEvent, loginEvent, readyEvent])
    }
    
    func changeSystemStateTo(_ state: ApplicationType) {
        switch state {
        case .placeGroup:
            if (applicationStateMachine?.fireEvent(placeGroupEvent).successful)! {
                loadCondition()
            }
        case .placeTerminal:
            if (applicationStateMachine?.fireEvent(placeTerminalEvent).successful)! {
                loadCondition()
            }
        case .objectGroup:
            if (applicationStateMachine?.fireEvent(objectGroupEvent).successful)! {
                loadCondition()
            }
        case .cloudGroup:
            if (applicationStateMachine?.fireEvent(cloudGroupEvent).successful)! {
                loadCondition()
            }
        default:
            if (applicationStateMachine?.fireEvent(readyEvent).successful)! {
                //LOG.debug("We didn't transition")
            }
        }
    }
    
    func checkApplicationState() -> ApplicationType {
        return applicationStateMachine!.currentState.value
    }
    
    func prepareBeacons() {
        estBeaconManager.delegate = self
        //estMonitoringManager.delegate = self
        
        estBeaconManager.requestAlwaysAuthorization()
        
        for (_, beaconId) in beaconIds.enumerated() {
            enableNotificationsForBeaconID(beaconId)
        }

    }
    
    func enableNotificationsForBeaconID(_ beaconId: BeaconID) {
        
        // Improves performance in background, but can impact the battery. Use with caution.
        
        let beaconRegion = beaconId.asBeaconRegion
        beaconRegion.notifyEntryStateOnDisplay = true
        beaconRegion.notifyOnExit = true
        beaconRegion.notifyOnEntry = true
        
        estBeaconManager.startMonitoring(for: beaconRegion)
    }
    
    func doEnter(identifier:String) {
        if let beaconId = findBeaconId(withId: identifier) {
            
            
            
            let region = beaconId.asBeaconRegion
            
            //adjust because these ids can't be start 0
            let speciesIndex = beaconId.speciesIndex
            
            let gim = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true)
            
//            if let autoScrollPageDelegate = self.autoScrollPageDelegate {
//                autoScrollPageDelegate.scroll(withIndex: speciesIndex)
//            }
            
            LOG.debug("\n\n DID ENTER ----------------> SPECIES: \(speciesIndex) REGION: \(region)")
            
            
            let banner = Banner(title: "DID ENTER", subtitle: "SPECIES \(speciesIndex)", image: gim, backgroundColor: UIColor.black)
            
            banner.shouldTintImage = false
            banner.dismissesOnTap = true
            banner.dismissesOnSwipe = true
            banner.show()
            
            //four sec
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                banner.dismiss()
            }
            
            realmDataController.syncSpeciesObservations(withSpeciesIndex: speciesIndex, withCondition: "place", withActionType: "enter", withPlace: region.description)
            
            play(sound: .coin)
            
            let userInfo = ["index":NSNumber.init(value: speciesIndex)]
            
            let notification = Notification(
                name: Notification.Name(rawValue: beaconNotificationKey), object: self,
                userInfo: userInfo)
            NotificationCenter.default.post(notification)
            
        } else {
            LOG.debug("FAILED ENTER \(identifier)")
        }
    }
    
    func doExit(identifier:String) {
        if let beaconId = findBeaconId(withId: identifier) {
            
            let region = beaconId.asBeaconRegion
            
            //self.enableNotificationsForBeaconID(beaconId)
            
            
            
            //adjust because these ids can't be start 0
            let speciesIndex = beaconId.speciesIndex
            
            
            let gim = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true)
            
            //realmDataController.syncSpeciesObservations(withIndex: speciesIndex)
            
            let banner = Banner(title: "DID EXIT", subtitle: "SPECIES \(speciesIndex)", image: gim, backgroundColor: UIColor.black)
            
            banner.shouldTintImage = false
            banner.dismissesOnTap = true
            banner.dismissesOnSwipe = true
            banner.show()
            
            LOG.debug("\n\n DID EXIT ----------------> SPECIES: \(speciesIndex) REGION: \(region)")
            
            //four sec
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                banner.dismiss()
            }
            
            if let groupIndex = realmDataController.getRealm().runtimeGroupIndex() {
                realmDataController.saveNutellaCondition(withCondition: "place", withActionType: "exit", withPlace: region.description, withGroupIndex: groupIndex, withSpeciesIndex: speciesIndex)
            }
            
            play(sound: .tap)
            
            let userInfo = ["index":NSNumber.init(value: speciesIndex)]
            
            let notification = Notification(
                name: Notification.Name(rawValue: beaconNotificationKey), object: self,
                userInfo: userInfo)
            NotificationCenter.default.post(notification)
            
        } else {
            LOG.debug("FAILED EXIT \(identifier)")
        }
    }
    
    var audioPlayer:AVAudioPlayer!

    func play(sound: Sound) {
        
        
        var audioFilePath: String?
        
        switch sound {
        case .tap:
            audioFilePath = Bundle.main.path(forResource: "tap", ofType: "wav")
        default:
            audioFilePath = Bundle.main.path(forResource: "coin", ofType: "wav")
        }
        
        do {
            if let path = audioFilePath {
                
                let url = NSURL.fileURL(withPath: path)
                
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
                
            } else {
                print("audio file is not found")
            }
        } catch {
            
        }
    }


    func findBeaconId(withId id: String) -> BeaconID? {
        let found = beaconIds.filter({ $0.asBeaconRegion.identifier == id })
        return found.first
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

extension AppDelegate: ESTBeaconManagerDelegate {
    
    func beaconManager(_ manager: Any, didChange status: CLAuthorizationStatus) {
        LOG.debug("\n\n STATUS ---> BEACON MANAGER REGION: \(status)")
        
        switch status {
        case .authorizedAlways:
            LOG.debug("\n\n authorizedAlways)")
        case .authorizedWhenInUse:
            LOG.debug("\n\n authorizedWhenInUse)")
        case .denied:
            LOG.debug("\n\n denied)")
        case .notDetermined:
            LOG.debug("\n\n not determined)")
        case .restricted:
            LOG.debug("\n\n restricted)")
        }
    }
    
    func beaconManager(_ manager: Any, didStartMonitoringFor region: CLBeaconRegion) {
        LOG.debug("\n\n DID START MONITOR BEACON MANAGER ---> BEACON MANAGER REGION: \(region)")
        
        if let bm = manager as? ESTBeaconManager {
            LOG.debug("--ranged regions \(bm.monitoredRegions.count)--")
        }
        
    }
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        LOG.debug("\n\n DID ENTER ---> BEACON MANAGER REGION: \(region)")
        doEnter(identifier: region.identifier)
        if let bm = manager as? ESTBeaconManager {
            LOG.debug("--ranged regions \(bm.monitoredRegions.count)--")
        }
        
    }
    
    func beaconManagerDidStartAdvertising(_ manager: Any, error: Error?) {
        LOG.debug("\n\n DID ADV ---> BEACON MANAGER")
        if let bm = manager as? ESTBeaconManager {
            LOG.debug("--ranged regions \(bm.monitoredRegions.count)--")
        }
        
        
    }
    
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
        LOG.debug("\n\n DID EXIT ---> BEACON MANAGER REGION: \(region)")
        doExit(identifier: region.identifier)
        if let bm = manager as? ESTBeaconManager {
            LOG.debug("--ranged regions \(bm.monitoredRegions.count)--")
        }
        
    }
    
    func beaconManager(_ manager: Any, didDetermineState state: CLRegionState, for region: CLBeaconRegion) {
        
        switch state {
        case .unknown:
            LOG.debug("\n\n UNKNOWN STATE ---> BEACON MANAGER REGION: \(region.identifier)")
        case .inside:
            doEnter(identifier: region.identifier)
            LOG.debug("\n\n INSIDE STATE ---> BEACON MANAGER REGION: \(region.identifier)")
        case .outside:
            LOG.debug("\n\n OUTSIDE STATE ---> BEACON MANAGER REGION: \(region.identifier)")
        default:
            break
        }
        
        if let bm = manager as? ESTBeaconManager {
            LOG.debug("--ranged regions \(bm.monitoredRegions.count)--")
        }
        
    }
    
    func beaconManager(_ manager: Any, didFailWithError error: Error) {
        LOG.debug("\n\n DID FAIL WITH ERROR \(manager) ----------------> BEACON MANAGER: \(error)")
        if let bm = manager as? ESTBeaconManager {
            LOG.debug("--ranged regions \(bm.monitoredRegions.count)--")
        }
        
    }
    
    func beaconManager(_ manager: Any, monitoringDidFailFor region: CLBeaconRegion?, withError error: Error) {
        LOG.debug("\n\n DID FAILE FOR  ---> BEACON MANAGER REGION: \(region) ERROR \(error)")
        if let bm = manager as? ESTBeaconManager {
            LOG.debug("--ranged regions \(bm.monitoredRegions.count)--")
        }
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

