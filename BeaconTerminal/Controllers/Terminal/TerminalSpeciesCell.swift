//
//  AggregateSpeciesCell.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 8/18/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit
import Material


@IBDesignable
class TerminalSpeciesCell: UIView {
    
    
    @IBOutlet var groupStatusViews: [UIView]!
    @IBOutlet weak var speciesImage: UIImageView!
    
    var speciesIndex: Int? 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareView()
    }
    
    func prepareView() {
        
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of:self)), bundle: bundle)
        
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        //nibView.translatesAutoresizingMaskIntoConstraints = false
        return nibView
        
    }

    func nibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.addSubview(view)
    }
    
    func allGroupStatusViewsOff() {
        for statusView in groupStatusViews {
            statusView.borderColor = UIColor.white
            statusView.backgroundColor = UIColor.white
        }
    }
    
    func groupStatusView(highlighted highlight: Bool = false, for groupIndex: Int) {
        for (index,statusView) in groupStatusViews.enumerated() {
            if highlight == false {
                statusView.borderColor = UIColor.lightGray
                statusView.backgroundColor = UIColor.white
                
                
                if let speciesIndex = self.speciesIndex {
                    self.speciesImage.image = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: false)
                }
                
            } else {
                
                
                if let speciesIndex = self.speciesIndex {
                    self.speciesImage.image = RealmDataController.generateImageForSpecies(speciesIndex, isHighlighted: true)                
                }
                
                var hightlightColor: UIColor?
                
                switch index {
                case 0:
                    hightlightColor = Color.pink.base
                case 1:
                    hightlightColor = Color.purple.base
                case 2:
                    hightlightColor = Color.blue.base
                case 3:
                    hightlightColor = Color.teal.base
                case 4:
                    hightlightColor = Color.brown.base
                default:
                    hightlightColor = Color.black
                }
                
                statusView.backgroundColor = hightlightColor
                statusView.borderColor = UIColor.lightGray
            }
        }
    }
    
    
}
