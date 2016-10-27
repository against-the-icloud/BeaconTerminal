//
//  SpeciesPageViewController.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 9/9/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class TerminalPageContainerController: UIPageViewController {
    
    var relationshipResults: Results<Relationship>?
    var preferencesResults: Results<SpeciesPreference>?
    var runtimeResults: Results<Runtime>?
    var speciesPreferenceResults: List<SpeciesPreference>?
    
    var speciesPreferenceNotification: NotificationToken? = nil
    var runtimeNotificationToken: NotificationToken? = nil
    var relationshipNotificaitonToken: NotificationToken? = nil
    var notificationTokens = [NotificationToken]()
    
    var sectionName = ""
    var speciesIndex = 0
    
    
    var pageCount = 0
    
    var pageIsAnimating = false
    
    
    deinit {
        relationshipNotificaitonToken?.stop()
        runtimeNotificationToken?.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        
        let pageControlAppearance = UIPageControl.appearance()
        pageControlAppearance.pageIndicatorTintColor = UIColor.black
        pageControlAppearance.currentPageIndicatorTintColor = UIColor.black
        pageControlAppearance.backgroundColor = UIColor.clear
        
        if needsTerminal {
            prepareNotifications()
            
            if let sectionName = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSectionName() {
                self.sectionName = sectionName
            } else {
                self.sectionName = "not specified"
            }
            
            if let speciesIndex = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSpeciesIndex() {
                self.speciesIndex = speciesIndex
            } else {
                self.speciesIndex = -1
            }
        }
    }
    
    func prepareNotifications() {
        runtimeResults = realmDataController.getRealm(withRealmType: .terminalDB).objects(Runtime.self)
        
        // Observe Notifications
        runtimeNotificationToken = runtimeResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let pageController = self else { return }
            switch changes {
            case .initial(let runtimeResults):
                if let runtime = runtimeResults.first {
                    pageController.updateFirstPage(withRuntime: runtime)
                }
                break
            case .update(let runtimeResults, _, _, _):
                if let runtime = runtimeResults.first {
                    pageController.updateFirstPage(withRuntime: runtime)
                }
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                LOG.error("\(error)")
                break
            }
        }
        
        if let r = runtimeNotificationToken {
            notificationTokens.append(r)
        }
        
        relationshipResults = realmDataController.getRealm(withRealmType: RealmType.terminalDB).objects(Relationship.self)
        
        relationshipNotificaitonToken = relationshipResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let controller = self else { return }
            switch changes {
            case .initial(let relationshipResults):
                controller.relationshipResults = relationshipResults
                //clear all the cells
                //                controller.reloadCells()
                //                controller.updateCells(withSpeciesObservationResults: speciesObservationResults)
                break
            case .update(let relationshipResults, _, _, _):
                controller.relationshipResults = relationshipResults
                break
            case .error(_):
                // An error occurred while opening the Realm file on the background worker thread
                //fatalError("\(error)")
                break
            }
        }
        
        
        if let s = relationshipNotificaitonToken {
            notificationTokens.append(s)
        }
        
        preferencesResults = realmDataController.getRealm(withRealmType: RealmType.terminalDB).objects(SpeciesPreference.self)
        
        speciesPreferenceNotification = preferencesResults?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            guard let controller = self else { return }
            switch changes {
            case .initial(let preferencesResults):
                controller.preferencesResults = preferencesResults
                //clear all the cells
                //                controller.reloadCells()
                //                controller.updateCells(withSpeciesObservationResults: speciesObservationResults)
                break
            case .update(let preferencesResults, _, _, _):
                controller.preferencesResults = preferencesResults
                break
            case .error(_):
                // An error occurred while opening the Realm file on the background worker thread
                //fatalError("\(error)")
                break
            }
        }
        
        
        if let s = speciesPreferenceNotification {
            notificationTokens.append(s)
        }
    }
    
    func updateUI() {
        print("hello")
    }
    
    func updateFirstPage(withRuntime runtime: Runtime) {
        if let firstPageController = viewController(atIndex: 0) {
            self.setViewControllers([firstPageController], direction: .forward, animated: true, completion: {done in })
        }
    }
    
    func computePageCount() -> Int {
        
        var pc = 0
        
        if let rr = relationshipResults {
            pc += rr.count
        }
        
        if let ss = preferencesResults {
            pc += ss.count
        }
        
        return pc
    }
    
    
    func viewController(atIndex index: Int) -> UIViewController? {
        
        var count = 1
        
        if let rr = relationshipResults, !rr.isEmpty {
            count = rr.count
        }
        
        
        switch index {
        case 0:
            let terminalPageStoryboard = UIStoryboard(name: "Terminal", bundle: nil)
            let terminalContainerController = terminalPageStoryboard.instantiateViewController(withIdentifier: "terminalContainerViewController") as! TerminalContainerViewController
            return terminalContainerController
            
        case 1...count:
            if let relationshipResults = self.relationshipResults, let speciesIndex = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSpeciesIndex() {
                
                
                if !relationshipResults.isEmpty {
                    
                    let offset = index - 1
                    
                    if offset < relationshipResults.count {
                        
                        let terminalPageStoryboard = UIStoryboard(name: "Terminal", bundle: nil)
                        let terminalPageContentViewController = terminalPageStoryboard.instantiateViewController(withIdentifier: "terminalPageContentController") as! TerminalPageContentController
                        
                        terminalPageContentViewController.index = index
                        
                        let relationship = relationshipResults[offset]
                        
                        if let so = realmDataController.getRealm(withRealmType: RealmType.terminalDB).speciesObservations(withRelationshipId: relationship.id!) {
                            terminalPageContentViewController.groupIndex = so.groupIndex
                        }
                        terminalPageContentViewController.fromSpeciesIndex = speciesIndex
                        terminalPageContentViewController.relationship = relationship
                        return terminalPageContentViewController
                    }
                }
                
            }
            
            return nil
        default:
            if let preferencesResults = self.preferencesResults, let speciesIndex = realmDataController.getRealm(withRealmType: RealmType.terminalDB).runtimeSpeciesIndex() {
                
                if !preferencesResults.isEmpty {
                    var offset = 0
                    
                    if let relationshipResults = relationshipResults {
                        let rcount = relationshipResults.count
                        
                        offset = index - (1 + rcount)
                        
                    } else {
                        offset = index - 1
                    }
                    
                    if offset < preferencesResults.count {
                        
                        let terminalPageStoryboard = UIStoryboard(name: "Terminal", bundle: nil)
                        let terminalPageContentViewController = terminalPageStoryboard.instantiateViewController(withIdentifier: "terminalPageContentController") as! TerminalPageContentController
                        
                        terminalPageContentViewController.index = index
                        
                        
                        
                        let speciesPreference = preferencesResults[offset]
                        
                        if let so = realmDataController.getRealm(withRealmType: RealmType.terminalDB).speciesObservations(withSpeciesPreferenceId: speciesPreference.id!) {
                            terminalPageContentViewController.groupIndex = so.groupIndex
                        }
                        terminalPageContentViewController.fromSpeciesIndex = speciesIndex
                        terminalPageContentViewController.speciesPreference = speciesPreference
                        return terminalPageContentViewController
                    }
                }
                
            }
        }
        
        return nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

// MARK: - Page View Controller Data Source
extension TerminalPageContainerController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished || completed {
            self.pageIsAnimating = false
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.pageIsAnimating = true
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if self.pageIsAnimating {
            return nil
        }
        
        var pageIndex = 0
        
        if let pageCount = viewController as? TerminalContainerViewController {
            pageIndex = 0
            
            pageIndex -= 1
            if pageIndex >= 0 {
                
                
                return self.viewController(atIndex: pageIndex)
            }
            
        } else if let pageContent = viewController as? TerminalPageContentController {
            pageIndex = pageContent.index!
            
            if (pageIndex == NSNotFound) {
                return nil
            }
            
            pageIndex -= 1
            if pageIndex >= 0 {
                LOG.info( ["condition":"BeaconTerminal.ApplicationType.placeTerminal", "activity":realmDataController.getActivity(),"timestamp": Date(),"event":"scrolled_to_species_note","fromSpeciesIndex":self.speciesIndex,"toSpeciesIndex":pageIndex,"sectionName":self.sectionName])
                return self.viewController(atIndex: pageIndex)
            }
        }
        
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if self.pageIsAnimating {
            return nil
        }
        
        var pageIndex = 0
        
        if let pageCount = viewController as? TerminalContainerViewController {
            pageIndex = 0
            
            pageIndex += 1
            if pageIndex >= 0 {
                
                return self.viewController(atIndex: pageIndex)
            }
        } else if let pageContent = viewController as? TerminalPageContentController {
            pageIndex = pageContent.index!
            
            if (pageIndex == NSNotFound) {
                return nil
            }
            
            pageIndex += 1
            if pageIndex >= 0 {
                
                LOG.info( ["condition":"BeaconTerminal.ApplicationType.placeTerminal", "activity":realmDataController.getActivity(),"timestamp": Date(),"event":"scrolled_to_species_note","fromSpeciesIndex":self.speciesIndex,"toSpeciesIndex":pageIndex,"sectionName":self.sectionName])
                
                return self.viewController(atIndex: pageIndex)
            }
        }
        
        return nil
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return computePageCount()
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let vcs = pageViewController.viewControllers else {
            return 0
        }
        
        if let page = vcs.first as? TerminalContainerViewController {
            return 0
        }
        
        if let page = vcs.first as? TerminalPageContentController, let index = page.index {
            return index
        }
        
        return 0
    }
    
    
}
