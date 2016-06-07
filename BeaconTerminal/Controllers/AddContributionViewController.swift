//
// Created by Anthony Perritano on 6/1/16.
// Copyright (c) 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material
import ChameleonFramework

class AddContributionViewController : UIViewController {


    @IBOutlet weak var observationView: ObservationView!
  
    @IBOutlet weak var reasonTextView: TextView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!

    @IBOutlet var draggableViews: [DraggableImageView]!
    var toolMenuDelegate: ToolMenuDelegate?
    var dropViewIndex = 0

    var speciesIndex = 0
    var observationId : String? //use enums


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @IBOutlet weak var reasonOutView: UIView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        changeSpecies(self.speciesIndex)
        let _border = CAShapeLayer()

        _border.strokeColor = UIColor.blackColor().CGColor
        _border.fillColor = nil
        _border.lineDashPattern = [4, 4]
        
        imageView1.layer.addSublayer(_border)
         imageView2.layer.addSublayer(_border)
         imageView3.layer.addSublayer(_border)
        
        observationView.observationDropView.isEditing = true
        var targetPoints = [CGPoint]()

        var i = 0
        for dview in draggableViews {
            dview.delegate = self
            dview.shouldCopy = true
            dview.tag = i
            targetPoints.append(CGPoint(x: 0,y: 0))
            i += 1
        }
        observationView.observationDropView.targetPoints = targetPoints
//        observationView.observationDropView.clearsContextBeforeDrawing = true
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    @IBAction func makeImageView(sender: AnyObject) {
        self.imageView1.image = self.observationView.observationDropView.captureImage()
    }

    func changeSpecies(speciesIndex: Int) {
        let speciesImage = DataManager.sharedInstance.generateImageForSpecies(speciesIndex)

        observationView.mainSpiecesImage.image = speciesImage
        if let  obsId = observationId {
            observationView.viewLabel.text = obsId
            self.title = "'\(obsId)' Relationships"
        }
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            let relationshipController = parent as? RelationshipsContributionViewController
            relationshipController?.dropViews[dropViewIndex].imageView.hidden = false
            relationshipController?.dropViews[dropViewIndex].imageView.image = self.observationView.observationDropView.captureImage()
        }
    }
    
    func updateSpeciesNoteEditors(speciesIndex: Int, image: UIImage) {
        //let foundSpecies = DataManager.sharedInstance.findSpecies(speciesIndex)
        let speciesColor = UIColor(averageColorFromImage: image)
//        let speciesColor = foundSpecies?.convertHexColor()
//        let lightSpeciesColor = speciesColor?.lightenByPercentage(50.0)
          reasonOutView.borderWidth = 2.0
          reasonOutView.borderColor = UIColor.blackColor()
          //reasonTextView.backgroundColor = speciesColor.lightenByPercentage(50.0)

    }

    @IBAction func photoAction(sender: UITapGestureRecognizer) {
        LOG.debug("IMAGE TAPPED")
        self.toolMenuDelegate?.onImageViewPresented((sender.view as? UIImageView)!)
    }
}

extension AddContributionViewController: DraggableViewDelegate {

    func onDroppedToTarget(sender: DraggableImageView) {
        //draw line
        LOG.debug("dropped! \(sender.tag)")
        sender.shouldSnapBack = false
        sender.shouldCopy = false



        let dview = draggableViews[sender.tag]
        dview.highlighted = true
        dview.userInteractionEnabled = false
        
        
        self.updateSpeciesNoteEditors(sender.tag, image: dview.image!)

        //self.observationView.observationDropView?.targetPoints.insert(sender.center, atIndex: sender.tag)
        self.observationView.observationDropView?.updatePath(sender.tag, pathPoint: sender.center)
        self.observationView.observationDropView?.setNeedsDisplay()
    }

    func isDragging(sender: DraggableImageView) {

        //it all ready has been dropped
        if !sender.shouldCopy {
            LOG.debug("dragging copy! \(sender.tag)")
            self.observationView.observationDropView?.updatePath(sender.tag, pathPoint: sender.center)
            self.observationView.observationDropView?.setNeedsDisplay()
        }
    }

    func onDraggingStarted(sender: DraggableImageView) {

    }

    func onSnappedBack(sender: DraggableImageView) {

    }

    func onCopied(copiedSender: DraggableImageView) {

    }
    func enteringZone(sender: DraggableImageView, targets: [UIView]) {
       LOG.debug("\(sender)")
        //self.observationView.observationDropView.borderColor = UIColor.greenColor()
    }
    func exitingZone(sender: DraggableImageView, targets: [UIView]) {
        LOG.debug("\(sender)")
        self.observationView.observationDropView.borderColor = UIColor.redColor()
    }
}
