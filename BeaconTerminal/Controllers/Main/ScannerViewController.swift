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
import Transporter

class ScannerViewController: UIViewController, ImmediateBeaconDetectorDelegate, ESTDeviceConnectableDelegate {
    
    enum ScanningState: String {
        case initial = "initial"
        case stopped = "stopped"
        case scanning = "scanning"
        case connecting = "connecting"
        case error = "error"
    }
    
    //init states
    let initialScannerState = State(ScanningState.initial)
    let stoppedState = State(ScanningState.stopped)
    let scanningState = State(ScanningState.scanning)
    let connectingState = State(ScanningState.connecting)
    let errorState = State(ScanningState.error)
    
    var scanningStateMachine: StateMachine<ScanningState>?
    
    let stopEvent = Event(name: "stopEvent", sourceValues: [ScanningState.scanning, ScanningState.connecting, ScanningState.initial, ScanningState.error],
                          destinationValue: ScanningState.stopped)
    
    let errorEvent = Event(name: "errorEvent", sourceValues: [ScanningState.scanning, ScanningState.connecting, ScanningState.initial],
                           destinationValue: ScanningState.error)
    
    let scanningEvent = Event(name: "scanningEvent", sourceValues: [ScanningState.initial],
                              destinationValue: ScanningState.scanning)
    
    let connectingEvent = Event(name: "connectingEvent", sourceValues: [ScanningState.scanning],
                                destinationValue: ScanningState.connecting)
    
    struct ErrorMessage {
        let title: String
        let message: String
    }
    
    var immediateBeaconDetector: ImmediateBeaconDetector!
    var immediateBeacon: ESTDeviceLocationBeacon!
    
    var connectionRetries = 0
    
    // MARK: Scanner Border
    let _border = CAShapeLayer()
    
    // MARK: User Interface
    
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
        
        scanningStateMachine = StateMachine(initialState: initialScannerState, states: [stoppedState, scanningState,connectingState, errorState])
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
        
        statusLabel.text = ""
        
        self.immediateBeaconDetector = ImmediateBeaconDetector(delegate: self)
        
        scanningStateMachine?.addEvents([connectingEvent, scanningEvent, errorEvent,stopEvent])
        
        initialScannerState.didEnterState = { state in
            self.statusLabel.text = "Starting scanner..."
        }
        
        scanningState.didEnterState = { state in
            self.statusLabel.text = "Scanning..."
            self.immediateBeaconDetector.start()
        }
        
        connectingState.didEnterState = { state in
            self.statusLabel.text = "Connecting..."
        }
        
        stoppedState.didEnterState = { state in
            self.statusLabel.text = "Scanning Stopped..."
            self.immediateBeaconDetector.stop()
        }
        
        errorState.didEnterState = { state in
            if (self.scanningStateMachine?.fireEvent(self.stopEvent).successful) != nil {
                let alertController = UIAlertController(title: "ERROR", message: "ERROR reading beacon", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scanningStateMachine?.fireEvent(self.scanningEvent)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.scanningStateMachine?.fireEvent(self.stopEvent)
        
    }
    
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
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: Immediate Beacon Detector
    
    func immediateBeaconDetector(immediateBeaconDetector: ImmediateBeaconDetector, didDiscoverBeacon beacon: ESTDeviceLocationBeacon) {
        
        self.scanningStateMachine?.fireEvent(self.connectingEvent)
        
        immediateBeacon = beacon
        immediateBeacon.delegate = self
        immediateBeacon.connect()
    }
    
    func immediateBeaconDetector(immediateBeaconDetector: ImmediateBeaconDetector, didFailDiscovery error: ImmediateBeaconDetectorError) {
        switch error {
        case .BluetoothDisabled:
            self.scanningStateMachine?.fireEvent(self.stopEvent)
            break
        default:
            self.scanningStateMachine?.fireEvent(self.errorEvent)
            break
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
    
    func estDeviceConnectionDidSucceed(_ device: ESTDeviceConnectable) {
        
        connectionRetries = 0
        
        immediateBeacon.delegate = nil
        
        self.scanningStateMachine?.fireEvent(self.stopEvent)
        
        if let lb = device as? ESTDeviceLocationBeacon, let settings = lb.settings {
            
            let minorValue = settings.iBeacon.minor.getValue()
            let majorValue = settings.iBeacon.major.getValue()
            
            _ = Int(majorValue)
            let speciesIndex = Int(minorValue) - 1
            if let beaconId = findBeaconMinor(withMinor: Int16(minorValue)) {
                
                guard speciesIndex >= 0 else {
                    return
                }
                
                //LOG.debug("----VALUE \(self.description):MAJOR:\(majorIndex):MINOR:\(minorValue):SPECIES \(speciesIndex)")
                
                realmDataController.updateInViewTerminal(withSpeciesIndex: speciesIndex, withCondition: "artifact", withPlace: beaconId.asString)
             
                lb.disconnect()
            }
            
        }
        
        
        
        
        
        
        
        self.dismiss(animated: true, completion: {
            
            
            
        })
    }
    
    func findBeaconMinor(withMinor minor: Int16) -> BeaconID? {
        let found = beaconIds.filter({ $0.asBeaconRegion.minor?.int16Value == minor })
        return found.first
    }
    
    func findBeaconId(withId id: String) -> BeaconID? {
        let found = beaconIds.filter({ $0.asBeaconRegion.identifier == id })
        return found.first
    }
    
    func estDevice(_ device: ESTDeviceConnectable, didFailConnectionWithError error: Error) {
        if !retryConnection() {
            self.scanningStateMachine?.fireEvent(self.errorEvent)
        }
    }
    
    func estDevice(_ device: ESTDeviceConnectable, didDisconnectWithError error: Error?) {
        if !retryConnection() {
            self.scanningStateMachine?.fireEvent(self.errorEvent)
        }
    }
    
    @IBAction func closeButton(sender: Any?) {
        
        LOG.debug("Scanner View Close Button Tapped")
        
        self.dismiss(animated: true, completion: {
            self.scanningStateMachine?.fireEvent(self.stopEvent)
            
            if self.immediateBeaconDetector != nil {
                self.immediateBeaconDetector.stop()
                if self.immediateBeacon != nil {
                    self.immediateBeacon.disconnect()
                }
            }
        })
        
    }
    
}
