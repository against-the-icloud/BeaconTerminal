////
////  ScannerViewController.swift
////  BeaconTerminal
////
////  Created by Anthony Perritano on 5/8/16.
////  Copyright © 2016 aperritano@gmail.com. All rights reserved.
////
//
import Foundation
import UIKit
import Material
import AVFoundation
import AudioToolbox

class ScannerViewController: UIViewController {

//
//enum ScanningState: StateType {
//    case Initial, Stopped, Scanning, Connecting, Error
//}
//
//struct ErrorMessage {
//    let title: String
//    let message: String
//}
//
//class ScannerViewController: UIViewController, ImmediateBeaconDetectorDelegate, ESTDeviceConnectableDelegate {
//    
//    var immediateBeaconDetector: ImmediateBeaconDetector!
//    var immediateBeacon: ESTDeviceLocationBeacon!
//    
//    var connectionRetries = 0
//    
    // MARK: Scanner Border
    let _border = CAShapeLayer()
//
//    // MARK: User Interface

    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
//
//    var tapSound : AVAudioPlayer?
//    var clickSound : AVAudioPlayer?
//    var coinSound : AVAudioPlayer?
//    
    let pulsator = Pulsator()
//
//    var machine: StateMachine<ScanningState, NoEvent>!
//    
//    var tags = [ ["0","#99cc33"], ["1", "#5A6372"], ["6", "#502B6E"] ]
//    
//    var selectedSpeciesIndex = 0
//    var selectedBeaconDetail : BeaconID?
//    
//    // declared system sound here
//    let systemSoundID: SystemSoundID = 1104
//    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scannerView.layer.addSublayer(pulsator)
        pulsator.position = CGPoint(x: scannerView.frame.width/2, y: scannerView.frame.height/2)
        pulsator.numPulse = 5
        pulsator.radius = scannerView.frame.width/2
        pulsator.animationDuration = 5
        pulsator.backgroundColor = Color.blue.base.cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scannerView.layer.superlayer?.insertSublayer(pulsator, below: scannerView.layer)
        pulsator.start()
    }
//
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
//        machine <- .Scanning
//    }
//    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
//        machine <- .Stopped
//    }
//    
//    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scannerView.layer.layoutIfNeeded()
        pulsator.position = scannerView.layer.position
        _border.path = UIBezierPath(roundedRect: scannerView.bounds, cornerRadius:scannerView.frame.width/2).cgPath
        _border.frame = scannerView.bounds
        
        _border.strokeColor = UIColor.black.cgColor
        _border.fillColor = nil
        _border.lineDashPattern = [4, 4]
        scannerView.layer.addSublayer(_border)
    }

//    func initEstimotes() {
//        self.immediateBeaconDetector = ImmediateBeaconDetector(delegate: self)
//        
//        machine = StateMachine<ScanningState, NoEvent>(state: .Initial) { machine in
//            machine.addRoute(.Any => .Scanning) { context in
//                
//                print("Scanning for beacons...")
//                
//                
//                //                self.statusLabel.text = "Scanning for beacons..."
//                //                self.restartButton.hidden = true
//                //                self.activityIndicator.hidden = false
//                
//                self.pulsator.start()
//                
//                self.immediateBeaconDetector.start()
//            }
//            
//            machine.addRoute(.Scanning => .Connecting) { context in
//                print("Connecting to beacon...")
//                //self.statusLabel.text = "Connecting to beacon..."
//                self.statusLabel.text = "Connecting to critter..."
//                
//                self.immediateBeaconDetector.stop()
//                
//                dispatch_on_main {
//                    // Do some UI stuff
//                    AudioServicesPlaySystemSound(1104)
//                    
//                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//                    
//                    self.coinSound?.play()
//                }
//            }
//            
//            machine.addRoute(.Any => .Stopped) { context in
//                print("Scanning stopped....")
//                
//                //                machine <- (.Error, ErrorMessage(title: "There was a problem scanning for beacons", message: "Try starting scanning again. If the problem persists, try turning Bluetooth off, then on again."))
//                
//                self.immediateBeaconDetector.stop()
//            }
//            
//            machine.addRoute(.Any => .Error) { context in
//                let errorMessage = context.userInfo as! ErrorMessage
//                
//                let alert = UIAlertController(title: errorMessage.title, message: errorMessage.message, preferredStyle: .Alert)
//                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
//                alert.addAction(action)
//                //self.presentViewController(alert, animated: true, completion: nil)
//                
//                machine <- .Stopped
//            }
//            
//            machine.addErrorHandler { event, fromState, toState, userInfo in
//                print("StateMachine 'error', event = \(event), fromState = \(fromState), toState = \(toState), userInfo = \(userInfo)")
//            }
//        }
//        
//    }
//
    

//
//    // MARK: Immediate Beacon Detector
//    
//    func immediateBeaconDetector(immediateBeaconDetector: ImmediateBeaconDetector, didDiscoverBeacon beacon: ESTDeviceLocationBeacon) {
//        machine <- .Connecting
//        
//        immediateBeacon = beacon
//        immediateBeacon.delegate = self
//        immediateBeacon.connect()
//    }
//    
//    func immediateBeaconDetector(immediateBeaconDetector: ImmediateBeaconDetector, didFailDiscovery error: ImmediateBeaconDetectorError) {
//        switch error {
//        case .BluetoothDisabled:
//            machine <- (.Stopped, "Turn Bluetooth on.")
//        default:
//            machine <- (.Error, ErrorMessage(title: "There was a problem scanning for beacons", message: "Try starting scanning again. If the problem persists, try turning Bluetooth off, then on again."))
//        }
//    }
//    
//    // MARK: Beacon connection
//    
//    func retryConnection() -> Bool {
//        if connectionRetries < 3 {
//            connectionRetries += 1
//            immediateBeacon.connect()
//            return true
//        } else {
//            connectionRetries = 0
//            return false
//        }
//    }
//    
//    func estDeviceConnectionDidSucceed(device: ESTDeviceConnectable) {
//        connectionRetries = 0
//        
//        immediateBeacon.delegate = nil
//        
//        machine <- .Stopped
//        
//        //        let sndurl = NSBundle.mainBundle().URLForResource(
//        //            "coin", withExtension: "wav")!
//        //        var snd : SystemSoundID = 0
//        //        AudioServicesCreateSystemSoundID(sndurl, &snd)
//        // AudioServicesPlaySystemSound(1104)
//        
//        //        AudioServicesPlaySystemSoundWithCompletion(systemSoundID) {
//        //            AudioServicesDisposeSystemSoundID(self.systemSoundID)
//        //        }
//        
//        //        coinSound?.volume = 1.0
//        //        coinSound?.prepareToPlay()
////        dispatch_on_main {
////            // Do some UI stuff
////            AudioServicesPlaySystemSound(1104)
////            
////            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
////            
////            self.coinSound?.play()
////        }
////        
//        
//        
//        
//        print("FOUND STOPPED")
//        //self.immediateBeacon.disconnect()
//                print("tags \(immediateBeacon.settings?.deviceInfo.tags.getValue())")
//                
//                let tags = immediateBeacon.settings?.deviceInfo.tags.getValue()
//                
//                var hexColor = ""
//                var index = 0
//                for tag in tags! {
//                    
//                    if tag.containsString("#") {
//                        hexColor = tag
//                    } else {
//                        index = Int(tag)!
//                        
//                    }
//                    //print("\(tag)")
//                }
//        
//        
//       // var tags = [ ["0","#99cc33"], ["1", "#5A6372"], ["6", "#502B6E"] ]
//
//        if index == 0 {
//            hexColor = "#99cc33"
//        } else if index == 6 {
//            hexColor = "#502B6E"
//        }
//        //let beaconDetail = BeaconID(index: index, hexColor: hexColor)
//        
//        selectedBeaconDetail = BeaconID(index: index, hexColor: hexColor)
//        
////        print("\(selectedBeaconDetail!.asSimpleDescription)")
//        
//
//        
//        self.performSegueWithIdentifier("unwindToHereFromScannerView", sender: self)
//
//    }
//    
//    func estDevice(device: ESTDeviceConnectable, didFailConnectionWithError error: NSError) {
//        if error.code == ESTDeviceLocationBeaconError.CloudVerificationFailed.rawValue {
//            if estimoteCloudReachable() {
//                machine <- (.Error, ErrorMessage(title: "Couldn't connect to beacon", message: "Beacon ownership verification failed. Try again, and if the problem persists, set this beacon aside and try another one."))
//            } else {
//                machine <- (.Error, ErrorMessage(title: "Couldn't connect to beacon", message: "Couldn't reach Estimote Cloud. Check your Internet connection, then try again."))
//            }
//        } else {
//            if !retryConnection() {
//                machine <- (.Error, ErrorMessage(title: "Couldn't connect to beacon", message: "Try again. If the problem persists, try restarting Bluetooth. If that doesn't help either, set this beacon aside and try another one. [Code \(error.code)]"))
//            }
//        }
//    }
//    
//    func estDevice(device: ESTDeviceConnectable, didDisconnectWithError error: NSError?) {
//        if !retryConnection() {
//            machine <- (.Error, ErrorMessage(title: "Beacon disconnected while connecting", message: "Try again. If the problem persists, try restarting Bluetooth. If that doesn't help either, set this beacon aside and try another one."))
//        }
//        
//    }
//    

        @IBAction func closeButton(sender: Any?) {
            //self.tapSound?.play()
            LOG.debug("Scanner View Close Button Tapped")
    
            self.dismiss(animated: true, completion: {
//                self.machine <- .Stopped
//    
//                if self.immediateBeaconDetector != nil {
//                    self.immediateBeaconDetector.stop()
//                    if self.immediateBeacon != nil {
//                        self.immediateBeacon.disconnect()
//                    }
//                }
//    
//                LOG.debug("UNWINDE unwindToHereFromScannerView")
//    
//                self.performSegueWithIdentifier("unwindToHereFromScannerView", sender: nil)
                
                
            })
            
        }

    
//    @IBAction func closeButton(sender: FabButton) {
//        //self.tapSound?.play()
//        LOG.debug("Scanner View Close Button Tapped")
//        
//        self.dismissViewControllerAnimated(true, completion: {
//            self.machine <- .Stopped
//            
//            if self.immediateBeaconDetector != nil {
//                self.immediateBeaconDetector.stop()
//                if self.immediateBeacon != nil {
//                    self.immediateBeacon.disconnect()
//                }
//            }
//            
//            LOG.debug("UNWINDE unwindToHereFromScannerView")
//            
//            self.performSegueWithIdentifier("unwindToHereFromScannerView", sender: nil)
//            
//            
//        })
//        
//    }
//    
//    // MARK: Sound Effects
//    
//    func setupSounds() {
//        if let clickSound = self.setupAudioPlayerWithFile("click", type:"wav") {
//            self.clickSound = clickSound
//        }
//        if let coinSound = self.setupAudioPlayerWithFile("coin", type:"wav") {
//            self.coinSound = coinSound
//        }
//        if let tapSound = self.setupAudioPlayerWithFile("tap", type:"wav") {
//            self.tapSound = tapSound
//        }
//    }
//    
//    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
//        //1
//        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
//        let url = NSURL.fileURLWithPath(path!)
//        
//        //2
//        var audioPlayer:AVAudioPlayer?
//        
//        // 3
//        do {
//            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
//            audioPlayer?.prepareToPlay()
//            audioPlayer?.volume = 1.0
//        } catch {
//            print("Player not available")
//        }
//        
//        return audioPlayer
//    }
//}

}
