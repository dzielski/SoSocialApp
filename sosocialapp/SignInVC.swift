//
//  SignInVC.swift
//  sosocialapp
//
//  Created by David Zielski on 8/11/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    

    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        emailField.delegate = self
        pwdField.delegate = self

        // Do any additional setup after loading the view.
    }

    //*****************************************************************
    // MARK: - viewDidAppear
    //*****************************************************************

    override func viewDidAppear(animated: Bool) {
        if let _ = KeychainWrapper.stringForKey(KEY_UID) {
            print("DZ: ID found in keychain")
            self.sendThemOnTheirWay()
        }
    }
    
    //*****************************************************************
    // MARK: - Buttons and Actions
    //*****************************************************************
    
    @IBAction func logInBtnTapped(sender: AnyObject) {
    
        guard let email = emailField.text where email != "" else {
            print("DZ: User Name must be entered")
            
            let alert = UIAlertController(title: "Email Address Is Empty", message: "You need to add a valid email address to log into the system or create an account.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        guard let pwd = pwdField.text where pwd != "" && pwd.characters.count >= 6 else {
            print("DZ: Password Pre check error")
            
            let alert = UIAlertController(title: "Password Is Incorrect", message: "You need to include a password of 6 characters or longer to log into the system or create an account.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // now that we have some basic error checking done, lets try and sign the user in
        FIRAuth.auth()!.signInWithEmail(email, password: pwd, completion: { (user, error) in
            if error == nil {
                print("DZ: Email user authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": user.providerID]
                    self.completeSignIn(user.uid, userData: userData)
                }
            } else {
                FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
                    if error != nil {
                        
                        print("DZ: Firebase sign in error = \(error?.localizedDescription)")
                        
                        print("DZ: Unable to authenticate user with email with Firebase - \(error)")
                        let alert = UIAlertController(title: "Login Information Incorrect", message: "There was an error with your username or password and the database. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        return
                    } else {
                        print("DZ: Sussusfully created and authenticated user with email with Firebase")
                        if let user = user {
                            let userData = ["provider": user.providerID]
                            
                            self.completeSignIn(user.uid, userData: userData)
                        }
                    }
                })
            }
        })
    }
    
    
    @IBAction func forgotPassTapped(sender: AnyObject) {
        performSegueWithIdentifier("forgotPassword", sender: nil)
    }

    
    //*****************************************************************
    // MARK: - Helper Functions
    //*****************************************************************

    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createUser(id, userData: userData )
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("DZ: Data saved to keychain = \(keychainResult)")
        
        // now check to see if they have a user name, if they do send them to the feed
        // if not send them to the profile page
        
        self.sendThemOnTheirWay()
        
    }

    
    // this fuction will be helpful when more methods of sign in are implemented
    func sendThemOnTheirWay() {
        
        // flush cache so we are fresssssh
        FeedVC.imageCache.removeAllObjects()
        FeedVC.profileImageCache.removeAllObjects()
        
        // start them on friends feed
        FeedType.ft.feedTypeToShow = FeedType.FeedTypeEnum.friendFeed
        
        DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            print("DZ: Snap userName = \(snapshot.value!["userName"]!)")
            print("DZ: Snap profileImage = \(snapshot.value!["imageURL"]!)")
            
            if (snapshot.value!["userName"]!) == nil {
                print("DZ: No Username associated with this user")
                self.performSegueWithIdentifier("noUserName", sender: nil)
            } else {
                self.performSegueWithIdentifier("loginToFeed", sender: nil)
                
            }
            
        })
    }

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
