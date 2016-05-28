//
// Created by Anthony Perritano on 5/27/16.
// Copyright (c) 2016 aperritano@gmail.com. All rights reserved.
//

import Foundation
import UIKit

class DraggableImageView: UIImageView {
    
//    weak var delegate: DragAndDrop
    var startLocation: CGPoint
    var copied: DraggableImageView
    
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


//override func touchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
//    self.copied = DraggableImageView(image: self.image())
//    self.copied.delegate = self.delegate
//    self.copied.frame = self.frame
//    self.superview().addSubview(self.copied)
//    var pt: CGPoint = touches.first!.locationInView(self.copied)
//    self.copied.startLocation = pt
//    self.copied.superview().bringSubviewToFront(self.copied)
//}