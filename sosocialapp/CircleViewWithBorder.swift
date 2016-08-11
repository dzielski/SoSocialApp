//
//  CircleViewWithBorder.swift
//  sosocialapp
//
//  Created by David Zielski on 8/10/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit


class CircleViewWithBorder: UIImageView {
    
    override func layoutSubviews() {
        
        layer.cornerRadius = self.frame.width / 2
        layer.borderColor = UIColor(red: WHITE, green: WHITE, blue: WHITE, alpha: 1.0).CGColor
        layer.borderWidth = 5.0
        clipsToBounds = true
    }
    
    
}