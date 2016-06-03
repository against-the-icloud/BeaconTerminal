import UIKit
import RealmSwift
import Material
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

func dispatch_on_main(block: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), block)
}

func getAppDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var realm: Realm?
    let bottomNavigationController: BottomNavigationController = BottomNavigationController()


    var beaconIDs =  [
        BeaconID(index: 0, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 54220, minor: 25460, beaconColor: MaterialColor.pink.base),
        BeaconID(index: 1, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 13198, minor: 13180, beaconColor: MaterialColor.yellow.base),
        BeaconID(index: 2, UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 15252, minor: 24173,beaconColor: MaterialColor.green.base)
    ]
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ESTConfig.setupAppID("location-configuration-07n", andAppToken: "f7532cffe8a1a28f9b1ca1345f1d647e")

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
        mainViewController.changeApplicationState(ApplicationState.PLACE_GROUP)

        let sideViewController = storyboard.instantiateViewControllerWithIdentifier("sideViewController") as! SideViewController
        let scratchPadViewController = storyboard.instantiateViewControllerWithIdentifier("scratchPadViewController") as! ScratchPadViewController


//        let menuViewController: AppMenuViewController = AppMenuViewController(rootViewController: mainViewController)
//        menuViewController.edgesForExtendedLayout = .None

        bottomNavigationController.viewControllers = [mainViewController, scratchPadViewController]
        bottomNavigationController.selectedIndex = 0
        bottomNavigationController.tabBar.tintColor = MaterialColor.white
        bottomNavigationController.tabBar.backgroundColor = MaterialColor.grey.darken4
        bottomNavigationController.tabBar.itemPositioning = UITabBarItemPositioning.Automatic
//        bottomNavigationController.tabBar.itemSpacing = 400.0
        
        
        // Configure the window with the SideNavigationController as the root view controller
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = SideNavigationController(rootViewController: bottomNavigationController, leftViewController: sideViewController)
        window?.makeKeyAndVisible()




        do {
            try NSFileManager.defaultManager().removeItemAtURL(Realm.Configuration.defaultConfiguration.fileURL!)
            
            
        } catch {}
        
        
        realm = try! Realm() // Create realm pointing to default file
        
        
        let dataManager = DataManager.sharedInstance
        dataManager.createDataStructure()
        
        
        LOG.debug("\(Realm.Configuration.defaultConfiguration.fileURL!)")
        
        
        return true
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