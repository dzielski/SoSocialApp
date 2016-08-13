//
//  PopUpVC.swift
//  sosocialapp
//
//  Created by David Zielski on 8/13/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class PopUpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        self.showAnimate()
        
        self.view.endEditing(true)

        // Do any additional setup after loading the view.
    }

    //*****************************************************************
    // MARK: - Buttons and Actions
    //*****************************************************************
    
    @IBAction func helpBtnTapped(sender: AnyObject) {
        self.removeAnimate()
        self.performSegueWithIdentifier("popupToHelp", sender: nil)    
    }
    
    
    @IBAction func logoutBtnTapped(sender: AnyObject) {
        self.removeAnimate()
        let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        print("DZ: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        self.performSegueWithIdentifier("popupToSignIn", sender: nil)
    }

    @IBAction func closeBtnTapped(sender: AnyObject) {
        self.removeAnimate()
    }
    
    //*****************************************************************
    // MARK: - Helper functions
    //*****************************************************************
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    
}
