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

class SpeciePageContainerController: UIPageViewController {
    
    var speciesObservationResults: Results<SpeciesObservation>?
    var runtimeResults: Results<Runtime>?
    var runtimeNotificationToken: NotificationToken? = nil
    var speciesObsNotificationToken: NotificationToken? = nil
    var pageCount = 0
    @IBOutlet var topToolbarDelegate: TopToolbarDelegate!
    
    deinit {
        speciesObsNotificationToken?.stop()
        runtimeNotificationToken?.stop()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        
        prepareNotifications()
        
        let pageControlAppearance = UIPageControl.appearance()
        pageControlAppearance.pageIndicatorTintColor = UIColor.gray
        pageControlAppearance.currentPageIndicatorTintColor = UIColor.black
        pageControlAppearance.backgroundColor = UIColor.clear
        
    }
    
    func prepareNotifications() {
        runtimeResults = realm?.objects(Runtime.self)
        
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
        
    }
    
    func updateUI() {
        print("hello")
    }
    
    func updateFirstPage(withRuntime runtime: Runtime) {
        if let firstPageController = viewController(atIndex: 0) {
            
            self.setViewControllers([firstPageController], direction: .forward, animated: true, completion: {done in })
            
            if let ttd = topToolbarDelegate {
                ttd.changeAppearance(withColor: UIColor.speciesColor(forIndex: 0, isLight: false))
            }
        }
    }

    
    func viewController(atIndex index: Int) -> UIViewController? {
        if let groupIndex = realm?.runtimeGroupIndex(), let sectionName = realm?.runtimeSectionName() {
            if let speciesObservations = realm?.group(withSectionName: sectionName, withGroupIndex: groupIndex)?.speciesObservations {
                
                pageCount = speciesObservations.count
                
                if index < speciesObservations.count {
                    
                    _ = speciesObservations[index]
                    let speciesPageStoryboard = UIStoryboard(name: "SpeciesPages", bundle: nil)
                    let pageContentViewController = speciesPageStoryboard.instantiateViewController(withIdentifier: "speciesContentPageController") as! SpeciesPageContentController
                    
                    pageContentViewController.speciesIndex = index
                    return pageContentViewController
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
extension SpeciePageContainerController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            
            guard let vcs = pageViewController.viewControllers else {
                return
            }
            
            if !vcs.isEmpty, let page = vcs.first as? SpeciesPageContentController, let index = page.speciesIndex{
                
                if let ttd = topToolbarDelegate {
                    ttd.changeAppearance(withColor: UIColor.speciesColor(forIndex: index, isLight: false))
                }
            }
            
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContent: SpeciesPageContentController = viewController as! SpeciesPageContentController
        if var index = pageContent.speciesIndex {
            if (index == NSNotFound) {
                return nil;
            }
            index -= 1
            if index >= 0 {
                return self.viewController(atIndex: index)                
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageContent: SpeciesPageContentController = viewController as! SpeciesPageContentController
        if var index = pageContent.speciesIndex {
            if (index == NSNotFound) {
                return nil;
            }
            index += 1
            
        
            
            return self.viewController(atIndex: index)
        }
        return nil
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageCount
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let vcs = pageViewController.viewControllers else {
            return 0
        }
        if let page = vcs.first as? SpeciesPageContentController, let index = page.speciesIndex {
            return index
        }
        return 0
    }
    

}
