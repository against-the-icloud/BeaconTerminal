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
    
    var scannedSpecies: Int?
    var scannedBeaconId: BeaconID?
    
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
    
    deinit {
        if immediateBeacon != nil {
            immediateBeacon.disconnect()
            immediateBeacon.delegate = nil
            immediateBeacon = nil
        }
        
    }
    
    
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
            
            if let sectionName = realmDataController.getRealm().runtimeSectionName() {
                
                LOG.info( ["condition":getAppDelegate().checkApplicationState().rawValue, "activity":realmDataController.getActivity(),"timestamp": Date(),"event":"start_scan_to_species_","sectionName":sectionName])
            }
            
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
        
        
        immediateBeacon = beacon
        
        //        LOG.debug("IS SHAKEN>>>>> \(beacon.isShaken)")
        //
        //        immediateBeacon.delegate = self
        //        immediateBeacon.connect()
        
        switch immediateBeacon.isShaken.boolValue {
        case true:
            LOG.debug("SKAKENING \(beacon.settings?.deviceInfo)")
            if immediateBeacon.isShaken.boolValue  {
                self.scanningStateMachine?.fireEvent(self.connectingEvent)
                
                
                LOG.debug("IS SHAKEN>>>>> \(self.immediateBeacon.isShaken)")
                
                
                doScan(scannedBeacon: immediateBeacon)
                
                //                immediateBeacon.delegate = self
                //                immediateBeacon.connect()
            }
        default:
            LOG.debug("NOT SHAKING \(self.immediateBeacon.settings?.deviceInfo)")
            
        }
        
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
            
            if let ib = immediateBeacon {
                immediateBeacon.connect()
                return true
            }
            
            return false
        } else {
            connectionRetries = 0
            return false
        }
    }
    
    func estDeviceConnectionDidSucceed(_ device: ESTDeviceConnectable) {
        connectionRetries = 0
        
        //immediateBeacon.delegate = nil
        
        self.scanningStateMachine?.fireEvent(self.stopEvent)
        
        if self.immediateBeaconDetector != nil {
            self.immediateBeaconDetector.stop()
        }
        
        if let ib = immediateBeacon {
            doScan(ib: ib)
            
        }
        
        
    }
    
    func doScan(scannedBeacon:ESTDeviceLocationBeacon) {
        if let beaconId = self.findBeaconId(withId: scannedBeacon.identifier) {
            
            
            
            let region = beaconId.asBeaconRegion
            
            //adjust because these ids can't be start 0
            let speciesIndex = beaconId.speciesIndex
            
            self.statusLabel.text = "Disconnecting..."
            
            
            self.dismiss(animated: true, completion: {
                
                if let sectionName = realmDataController.getRealm().runtimeSectionName() {
                    LOG.info( ["condition":getAppDelegate().checkApplicationState().rawValue, "activity":realmDataController.getActivity(),"timestamp": Date(),"event":"success_scan_to_species_","sectionName":sectionName, "speciesIndex":speciesIndex,"beaconId": beaconId.asString])
                }
                
                if getAppDelegate().checkApplicationState().rawValue != nil {
                    let condition = getAppDelegate().checkApplicationState().rawValue
                    //realmDataController.clearInViewTerminal(withCondition: condition)
                    realmDataController.syncSpeciesObservations(withSpeciesIndex: speciesIndex, withCondition: condition, withActionType: "enter", withPlace: "species:\(speciesIndex)")
                    realmDataController.updateInViewTerminal(withSpeciesIndex: speciesIndex, withCondition: "artifact", withPlace: beaconId.asString)
                } else {
                    print("no condition")
                }
                
            })
            
        }
    }
    
    func doScan(ib:ESTDeviceLocationBeacon) {
        if let settings = ib.settings {
            
            let minorValue = settings.iBeacon.minor.getValue()
            let majorValue = settings.iBeacon.major.getValue()
            
            _ = Int(majorValue)
            let speciesIndex = Int(minorValue) - 1
            if let beaconId = self.findBeaconMinor(withMinor: Int16(minorValue)) {
                
                guard speciesIndex >= 0 else {
                    return
                }
                
                self.scannedSpecies = speciesIndex
                self.scannedBeaconId = beaconId
                
                
                
                self.statusLabel.text = "Disconnecting..."
                
                
                self.dismiss(animated: true, completion: {
                    
                    
                    if let sectionName = realmDataController.getRealm().runtimeSectionName() {
                        
                        LOG.info( ["condition":getAppDelegate().checkApplicationState().rawValue, "activity":realmDataController.getActivity(),"timestamp": Date(),"event":"success_scan_to_species_","sectionName":sectionName, "speciesIndex":self.scannedSpecies,"beaconId":self.scannedBeaconId?.asString])
                    }
                    
                    if getAppDelegate().checkApplicationState().rawValue != nil {
                        
                        let condition = getAppDelegate().checkApplicationState().rawValue
                        //realmDataController.clearInViewTerminal(withCondition: condition)
                        realmDataController.syncSpeciesObservations(withSpeciesIndex: self.scannedSpecies!, withCondition: condition, withActionType: "enter", withPlace: "species:\(self.scannedSpecies)")
                        realmDataController.updateInViewTerminal(withSpeciesIndex: self.scannedSpecies!, withCondition: "artifact", withPlace: (self.scannedBeaconId?.asString)!)
                        
                        
                        ib.disconnect()
                        
                        
                        
                        
                    } else {
                        print("no condition")
                    }
                    
                })
                
                
                
                
                
                
                //lb.disconnect()
                
                //self.performSegue(withIdentifier: "unwindToMainFromScannerWithSegue", sender: self)
                
                //lb.disconnect()
            }
        }
    }
    
    
    func estDevice(_ device: ESTDeviceConnectable, didFailConnectionWithError error: Error) {
        
        if error._code == ESTDeviceLocationBeaconError.cloudVerificationFailed.rawValue {
            
            LOG.debug("Couldn't reach Estimote Cloud. Check your Internet connection, then try again.")
            
            if let sectionName = realmDataController.getRealm().runtimeSectionName() {
                
                LOG.info( ["condition":getAppDelegate().checkApplicationState().rawValue, "activity":realmDataController.getActivity(),"timestamp": Date(),"event":"fail_scan_to_species_","sectionName":sectionName])
            }
            
            
        } else {
            if error != nil {
                
                
                if let sectionName = realmDataController.getRealm().runtimeSectionName() {
                    
                    LOG.info( ["condition":getAppDelegate().checkApplicationState().rawValue, "activity":realmDataController.getActivity(),"timestamp": Date(),"event":"fail_scan_to_species_","sectionName":sectionName])
                }
                
                
                print("fail try")
                
                if let ib = immediateBeacon {
                    doScan(ib: ib)
                }
                //doScan(ib: device)
                if !retryConnection() {
                    if let ibd = immediateBeaconDetector {
                        ibd.stop()
                        ibd.start()
                    }
                }
                self.scanningStateMachine?.fireEvent(self.scanningEvent)
                
            }
            
            
        }
        
    }
    
    
    func estDevice(_ device: ESTDeviceConnectable, didDisconnectWithError error: Error?) {
        
        
        connectionRetries = 0
        if immediateBeacon != nil {
            
            immediateBeacon.delegate = nil
            immediateBeacon = nil
        }
        
        //        if error == nil {
        //            self.performSegue(withIdentifier: "unwindToMainFromScannerWithSegue", sender: self)
        //        }
        
        
    }
    
    @IBAction func closeButton(sender: Any?) {
        
        
        connectionRetries = 0
        
        if immediateBeacon != nil {
            immediateBeacon.disconnect()
            immediateBeacon.delegate = nil
            immediateBeacon = nil
        }
        
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
    
    func findBeaconMinor(withMinor minor: Int16) -> BeaconID? {
        let found = beaconIds.filter({ $0.asBeaconRegion.minor?.int16Value == minor })
        return found.first
    }
    
    func findBeaconId(withId id: String) -> BeaconID? {
        let found = beaconIds.filter({ $0.asBeaconRegion.identifier == id })
        return found.first
    }
    
}
