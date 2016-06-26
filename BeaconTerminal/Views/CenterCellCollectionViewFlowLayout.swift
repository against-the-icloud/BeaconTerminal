//
//  CenterCellCollectionViewFlowLayout.swift
//  BeaconTerminal
//
//  Created by Anthony Perritano on 6/12/16.
//  Copyright © 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {


    //how far to scroll before it gets to the center
    var ACTIVE_DISTANCE : CGFloat = 200.0
    
    var TAB_BAR_OFFSET : CGFloat = 49.0
    
    let ZOOM_FACTOR : CGFloat = 0.1
    


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init() {
        super.init()
        self.setup()
    }
    
    func setup() {
//        self.sectionInset = UIEdgeInsetsMake(200.0, 0.0, 200.0, 0.0)
//        self.minimumLineSpacing = 50.0
    }

    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offsetAdjustmentX = CGFloat(MAXFLOAT)
        var offsetAdjustmentY = CGFloat(MAXFLOAT)

        let horizontalCenter : CGFloat = proposedContentOffset.x + (CGRectGetWidth((self.collectionView?.bounds)!)/2.0)
        let targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView!.bounds.size.width, self.collectionView!.bounds.size.height)
        
        guard let superArray = super.layoutAttributesForElementsInRect(targetRect) else { return CGPointZero }
        
        // copy items
        guard let array = NSArray(array: superArray, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return CGPointZero }
        
//        let array = super.layoutAttributesForElementsInRect(targetRect)
        for at in array {
            let layoutAttributes = at as? UICollectionViewLayoutAttributes
            let itemHorizontalCenter = layoutAttributes!.center.x
            if( abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustmentX)) {
                offsetAdjustmentX = itemHorizontalCenter - horizontalCenter
            }
            let itemVerticalCenter = layoutAttributes!.center.y

            if( abs(itemVerticalCenter - itemVerticalCenter) < abs(offsetAdjustmentY)) {
                offsetAdjustmentY = itemVerticalCenter - itemVerticalCenter
            }
        }

        return CGPointMake(proposedContentOffset.x + offsetAdjustmentX, proposedContentOffset.y)
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //ACTIVE_DISTANCE = itemSize.width
        
        guard let superArray = super.layoutAttributesForElementsInRect(rect) else { return nil }
        
        // copy items
        guard let array = NSArray(array: superArray, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }


        //let array = super.layoutAttributesForElementsInRect(rect).
        let visibleRect = CGRect(origin: (self.collectionView?.contentOffset)!, size: (self.collectionView?.bounds.size)!)
        for at in array {
            let attributes = at as? UICollectionViewLayoutAttributes
            
   
            
            //find the insets
          

            
//            LOG.debug("VIS \(visibleRect)")
//            
//             let totalOffset = visibleRect.height - (attributes?.frame.height)!
//             let halfCell = (attributes?.frame.height)! / 2.0
//            let adjustedOffset = totalOffset/2
//            
//            LOG.debug("FRAME Y \(attributes?.frame)")
//            
//            LOG.debug("ATT Y \(attributes?.center.y)")
//            attributes?.center.y = adjustedOffset + totalOffset

            
            if CGRectIntersectsRect((attributes?.frame)!, rect) {
                
                //do center
                
                //collection cell frame - tabbar (because it underlaps)
                let adjustedVisibleHeight = (collectionView?.frame.size.height)! - TAB_BAR_OFFSET
                
                let centerVisibleRectY = adjustedVisibleHeight / 2.0
                
                //found visible area - cell.height
                let totalOffset = adjustedVisibleHeight - (attributes?.frame.height)!
                
                //get the top and bottom gaps
                let gap : CGFloat = totalOffset/2
                
                
                let newCenter = gap  + ((attributes?.frame.height)!/2.0) - (TAB_BAR_OFFSET/2)
                
                attributes?.center.y = newCenter
                
                //x
                
                let distance = CGRectGetMidX(visibleRect) - (attributes?.center.x)!
                
                
                let normalizeDistance : CGFloat = distance / ACTIVE_DISTANCE
                if abs(distance) < ACTIVE_DISTANCE {
                    let zoom =  1 + ZOOM_FACTOR * CGFloat((1-abs(normalizeDistance)))
                    attributes?.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
                    attributes?.zIndex = Int(round(zoom))
                }
            }
            
        }
        return array
    }
    
    func indexPathIsCentered(indexPath: NSIndexPath) -> Bool {
        let visibleRect = CGRectMake(self.collectionView!.contentOffset.x,
                                     self.collectionView!.contentOffset.y, CGRectGetWidth(self.collectionView!.bounds), CGRectGetHeight(self.collectionView!.bounds))
        let attributes = self.layoutAttributesForItemAtIndexPath(indexPath)
        let distanceFromVisibleRectToItem = CGRectGetMidX(visibleRect) - attributes!.center.x
        return fabs(distanceFromVisibleRectToItem) < 1
    }
}