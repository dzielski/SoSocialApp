//
//  FancyFieldtextBox.swift
//  sosocialapp
//
//  Created by David Zielski on 8/10/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit

class FancyFieldTextBox: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor(red: SHADOW_GREY, green: SHADOW_GREY, blue: SHADOW_GREY, alpha: 0.2).CGColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 2.0
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
//        var newBounds = bounds
//        newBounds.origin.x += leftTextMargin
//        return newBounds
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
//        var newBounds = bounds
//        newBounds.origin.x += leftTextMargin
//        return newBounds
    }
    
}