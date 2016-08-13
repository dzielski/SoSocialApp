//
//  MenuePopUpView.swift
//  sosocialapp
//
//  Created by David Zielski on 8/13/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit

class MenuPopUpView: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor(red: SHADOW_GREY, green: SHADOW_GREY, blue: SHADOW_GREY, alpha: 0.2).CGColor
        layer.borderWidth = 2.0
        layer.cornerRadius = 8.0
    }


}