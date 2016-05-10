//
//  ScannerViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 5/8/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import Pulsator
import Spring
import IBAnimatable
import SwiftState

enum ScanningState: StateType {
    case Initial, Stopped, Scanning, Connecting, Error
}

struct ErrorMessage {
    let title: String
    let message: String
}

class ScannerViewController: UIViewController, ImmediateBeaconDetectorDelegate, ESTDeviceConnectableDelegate {
    
    var immediateBeaconDetector: ImmediateBeaconDetector!
    var immediateBeacon: ESTDeviceLocationBeacon!
    
    var connectionRetries = 0
    
    // MARK: Scanner Border
    let _border = CAShapeLayer()
    
    // MARK: User Interface
    
    
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    let pulsator = Pulsator()

    var machine: StateMachine<ScanningState, NoEvent>!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scannerView.layer.addSublayer(pulsator)
        pulsator.position = CGPointMake(scannerView.frame.width/2, scannerView.frame.height/2)
        pulsator.numPulse = 5
        pulsator.radius = scannerView.frame.width/2
        pulsator.animationDuration = 5
        pulsator.backgroundColor = UIColor.redColor().CGColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        machine <- .Scanning
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        machine <- .Stopped
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _border.path = UIBezierPath(roundedRect: scannerView.bounds, cornerRadius:scannerView.frame.width/2).CGPath
        _border.frame = scannerView.bounds
    }
    
  
    func setup() {
        initEstimotes()
        renderViews()
    }
    
    func initEstimotes() {
        self.immediateBeaconDetector = ImmediateBeaconDetector(delegate: self)
        
        machine = StateMachine<ScanningState, NoEvent>(state: .Initial) { machine in
            machine.addRoute(.Any => .Scanning) { context in
                
                LOG.debug("Scanning for beacons...")
                

//                self.statusLabel.text = "Scanning for beacons..."
//                self.restartButton.hidden = true
//                self.activityIndicator.hidden = false
                
                self.pulsator.start()
                
                self.immediateBeaconDetector.start()
            }
            
            machine.addRoute(.Scanning => .Connecting) { context in
                LOG.debug("Connecting to beacon...")
                //self.statusLabel.text = "Connecting to beacon..."
                self.statusLabel.text = "Connecting to critter..."

                self.immediateBeaconDetector.stop()
            }
            
            machine.addRoute(.Any => .Stopped) { context in
                LOG.debug("Scanning stopped....")
                
                machine <- (.Error, ErrorMessage(title: "There was a problem scanning for beacons", message: "Try starting scanning again. If the problem persists, try turning Bluetooth off, then on again."))
                
                self.immediateBeaconDetector.stop()
            }
            
            machine.addRoute(.Any => .Error) { context in
                let errorMessage = context.userInfo as! ErrorMessage
                
                let alert = UIAlertController(title: errorMessage.title, message: errorMessage.message, preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                
                machine <- .Stopped
            }
            
            machine.addErrorHandler { event, fromState, toState, userInfo in
                LOG.debug("StateMachine 'error', event = \(event), fromState = \(fromState), toState = \(toState), userInfo = \(userInfo)")
            }
        }
        
    }
    
    func renderViews() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clearColor()
            
            let blurEffect = UIBlurEffect(style: .ExtraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            self.view.insertSubview(blurEffectView, atIndex: 0)
        } else {
            self.view.backgroundColor = UIColor.whiteColor()
        }
        
        _border.strokeColor = UIColor.blackColor().CGColor
        _border.fillColor = nil
        _border.lineDashPattern = [4, 4]
        scannerView.layer.addSublayer(_border)
    }
    
    // MARK: Immediate Beacon Detector
    
    func immediateBeaconDetector(immediateBeaconDetector: ImmediateBeaconDetector, didDiscoverBeacon beacon: ESTDeviceLocationBeacon) {
        machine <- .Connecting
        
        immediateBeacon = beacon
        immediateBeacon.delegate = self
        immediateBeacon.connect()
    }
    
    func immediateBeaconDetector(immediateBeaconDetector: ImmediateBeaconDetector, didFailDiscovery error: ImmediateBeaconDetectorError) {
        switch error {
        case .BluetoothDisabled:
            machine <- (.Stopped, "Turn Bluetooth on.")
        default:
            machine <- (.Error, ErrorMessage(title: "There was a problem scanning for beacons", message: "Try starting scanning again. If the problem persists, try turning Bluetooth off, then on again."))
        }
    }
    
    // MARK: Beacon connection
    
    func retryConnection() -> Bool {
        if connectionRetries < 3 {
            connectionRetries += 1
            immediateBeacon.connect()
            return true
        } else {
            connectionRetries = 0
            return false
        }
    }
    
    func estDeviceConnectionDidSucceed(device: ESTDeviceConnectable) {
        connectionRetries = 0
        
        immediateBeacon.delegate = nil
        
        //performSegueWithIdentifier("ShowBeaconSetup", sender: self)
    }
    
    func estDevice(device: ESTDeviceConnectable, didFailConnectionWithError error: NSError) {
        if error.code == ESTDeviceLocationBeaconError.CloudVerificationFailed.rawValue {
            if estimoteCloudReachable() {
                machine <- (.Error, ErrorMessage(title: "Couldn't connect to beacon", message: "Beacon ownership verification failed. Try again, and if the problem persists, set this beacon aside and try another one."))
            } else {
                machine <- (.Error, ErrorMessage(title: "Couldn't connect to beacon", message: "Couldn't reach Estimote Cloud. Check your Internet connection, then try again."))
            }
        } else {
            if !retryConnection() {
                machine <- (.Error, ErrorMessage(title: "Couldn't connect to beacon", message: "Try again. If the problem persists, try restarting Bluetooth. If that doesn't help either, set this beacon aside and try another one. [Code \(error.code)]"))
            }
        }
    }
    
    func estDevice(device: ESTDeviceConnectable, didDisconnectWithError error: NSError?) {
        if !retryConnection() {
            machine <- (.Error, ErrorMessage(title: "Beacon disconnected while connecting", message: "Try again. If the problem persists, try restarting Bluetooth. If that doesn't help either, set this beacon aside and try another one."))
        }
        
    }
}