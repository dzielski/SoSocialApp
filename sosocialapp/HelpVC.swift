//
//  HelpVC.swift
//  sosocialapp
//
//  Created by David Zielski on 8/12/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit

class HelpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HelpVC.backToFeed))
        view.addGestureRecognizer(tap)
    }

    //*****************************************************************
    // MARK: - Helper Functions
    //*****************************************************************
    
    
    //Calls this function when the tap is recognized.
    func backToFeed() {
        self.performSegueWithIdentifier("helpToFeed", sender: nil)
    }

}
