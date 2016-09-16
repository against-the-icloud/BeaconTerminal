    import UIKit
import RealmSwift
import Material
import XCGLogger
import Nutella
import Transporter

let DEBUG = true
let REFRESH_DB = true
let EXPORT_DB = true

// localhost || remote
let HOST = "local"
let REMOTE = "ltg.evl.uic.edu"
let LOCAL = "localhost"
let LOCAL_IP = "10.0.1.6"
var CURRENT_HOST = REMOTE
var SECTION_NAME = "default"

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


var groupSectionRealm: Realm?
    
var realm: Realm?
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
        
        
        
        
        prepareViews(applicationType: ApplicationType.placeGroup)
        
        prepareGroupSectionDB()
        
        //prepareDB(withSectionName: SECTION_NAME)
        
        UIView.hr_setToastThemeColor(UIColor.black())
        
        
        CURRENT_HOST = LOCAL
        
        setupConnection()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        return true
    }
    
    // Mark: View setup
    
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
            application = preparePlaceGroupUI()
            
            //show login for section and group
            
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
        
        let navigationController: AppNavigationController = AppNavigationController(rootViewController: mainViewController)
        let navigationDrawerController = NavigationDrawerController(rootViewController: navigationController, leftViewController:sideViewController)
        
        navigationController.isNavigationBarHidden = true
        navigationController.statusBarStyle = .default
        
        BadgeUtil.badge(shouldShow: false)
        
        speciesViewController = SpeciesMenuViewController()
        speciesViewController!.showSpeciesMenu(showHidden: false)
        
        sideViewController.showSelectedCell(with: checkApplicationState())
        
        return navigationDrawerController
    }
    
    func preparePlaceGroupUI() -> NavigationDrawerController{
        let terminalStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let terminalViewController = terminalStoryboard.instantiateViewController(withIdentifier: "mainContainerController") as! MainContainerController
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let sideViewController = mainStoryBoard.instantiateViewController(withIdentifier: "sideViewController") as! SideViewController
        
        let navigationController: AppNavigationController = AppNavigationController(rootViewController: terminalViewController)
        let navigationDrawerController = NavigationDrawerController(rootViewController: navigationController, leftViewController:sideViewController)
        
        navigationController.isNavigationBarHidden = true
        navigationController.statusBarStyle = .default
        
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
    
    // Mark: db setup
    
    func prepareGroupSectionDB() {
        if Platform.isSimulator {
            let testRealmURL = URL(fileURLWithPath: "/Users/aperritano/Desktop/Realm/BeaconTerminalGroupSection.realm")
            try! groupSectionRealm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
        } else {
            //TODO
            //device config
            setDefaultGroupSectionRealm()
        }
        
        
        RealmDataController.deleteAllConfigurationAndGroupsSectionGroupRealm()
        //re-up
        RealmDataController.parseUserGroupConfigurationJsonWithGroupRealm()
    }
    
    func prepareDB(withSectionName sectionName: String) {
        
        if Platform.isSimulator {
            let testRealmURL = URL(fileURLWithPath: "/Users/aperritano/Desktop/Realm/BeaconTerminal\(sectionName).realm")
            try! realm = Realm(configuration: Realm.Configuration(fileURL: testRealmURL))
        } else {
            //TODO
            //device config
            setDefaultRealm(withSectionName: sectionName)
        }
        
        realmDataController = RealmDataController()
        
        switch checkApplicationState() {
        case .placeGroup:
            realmDataController?.deleteAllConfigurationAndGroups()
            _ = realmDataController?.parseNutellaConfigurationJson()
            _ = realmDataController?.parseUserGroupConfigurationJson(withSimConfig: (realmDataController?.parseSimulationConfigurationJson())!, withPlaceHolders: true)
            break
        case .placeTerminal:
            realmDataController?.deleteAllConfigurationAndGroups()
            //re-up
            _ = realmDataController?.parseNutellaConfigurationJson()
            _ = realmDataController?.parseUserGroupConfigurationJson(withSimConfig: (realmDataController?.parseSimulationConfigurationJson())!)
            break
        default:
            break
        }
    }
    func setDefaultGroupSectionRealm() {
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("GroupSection.realm")
        
        // Set this as the configuration used for the default Realm
        //Realm.Configuration.defaultConfiguration = config
        
        try! groupSectionRealm = Realm(configuration: config)
    }

    
    func setDefaultRealm(withSectionName sectionName: String) {
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(sectionName).realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        try! realm = Realm(configuration: Realm.Configuration.defaultConfiguration)
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
    
    func setupConnection() {
        
        switch checkApplicationState() {
        case .placeGroup:
            nutella = Nutella(brokerHostname: CURRENT_HOST,
                              appId: "wallcology",
                              runId: "default",
                              componentId: ApplicationType.placeGroup.rawValue, netDelegate: self)
            break
        case .placeTerminal:
            nutella = Nutella(brokerHostname: CURRENT_HOST,
                              appId: "wallcology",
                              runId: "default",
                              componentId: ApplicationType.placeTerminal.rawValue, netDelegate: self)
            break
        default:
            break
        }
        
        
     
        let sub_1 = "note_changes"
        let sub_2 = "echo_out"
       // let sub_3 = "set_current_run"
        nutella?.net.subscribe(sub_1)
        nutella?.net.subscribe(sub_2)
        
        var dict = [String:String]()
        dict["HEY_NOW_MAN"] = "HELLO"
        
        nutella?.net.publish("echo_in", message: dict as AnyObject)
        //nutella?.net.subscribe(sub_3)
        Util.makeToast("Subscribed to \(sub_1):\(sub_2)")
        resetDB()
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
        realmDataController?.processNutellaUpdate(nutellaUpdate: nutellaUpdate)
        LOG.debug("----- Response Recieved on: \(channel) from: \(from) -----")
    }
    
    func messageReceived(_ channel: String, message: Any, from: [String : String]) {
        var nutellaUpdate = NutellaUpdate()
        nutellaUpdate.channel = channel
        nutellaUpdate.message = message
        nutellaUpdate.updateType = .message
        realmDataController?.processNutellaUpdate(nutellaUpdate: nutellaUpdate)
        LOG.debug("----- PubSub Recieved on: \(channel) from: \(from) with: \(message)-----")
        //once recieved set_run runid
        //check run, async 'get_current_run"
        //if cool, request 'roster', give portal types 'group', get list of groups,
        //get species names - terminal 
    }
    
}
