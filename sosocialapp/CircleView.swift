//
//  CircleView.swift
//  sosocialapp
//
//  Created by David Zielski on 8/10/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }
    
}

