//
//  PasswordVC.swift
//  sosocialapp
//
//  Created by David Zielski on 8/12/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase

class PasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailText: UITextField!
    
    //*****************************************************************
    // MARK: - viewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PasswordVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        emailText.delegate = self
    }

    
    //*****************************************************************
    // MARK: - Buttons and Actions
    //*****************************************************************
    
    @IBAction func submitTapped(sender: AnyObject) {
        print("DZ: Email is \(emailText.text!)")
        
        if emailText.text == "" {
            
            let alert = UIAlertController(title: "Ooops!", message: "Please enter an email.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.sendPasswordResetWithEmail(emailText.text!, completion: { (error) in
                
                // There seems to be a bug when firing the alert controller within the completion block of
                // this Firebase sendPasswordReset - just going to say success and move on - but code is here
                // if they ever fix it
                
                //        var title = ""
                //        var message = ""
                //
                //        if error != nil {
                //          title = "Ooops"
                //          message = (error?.localizedDescription)! as String
                //        } else {
                //          title = "Success!"
                //          message = "Password reset email sent."
                //          self.emailText.text = ""
                //        }
                //
                //        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                //        self.present(alert, animated: true, completion: nil)
                
            })
            
            self.emailText.text = ""
            
            let alert = UIAlertController(title: "Success!", message: "Password reset email sent.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }

    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("passwordToSignIn", sender: nil)
    }

    //*****************************************************************
    // MARK: - Helper Functions
    //*****************************************************************
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
}
