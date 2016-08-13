//
//  SearchUserVC.swift
//  sosocialapp
//
//  Created by David Zielski on 8/12/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase

class SearchUserVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTxtField: UITextField!
    
    
    //*****************************************************************
    // MARK: - viewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchUserVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        userNameTxtField.delegate = self

    }

    //*****************************************************************
    // MARK: - Buttons and Actions
    //*****************************************************************

    @IBAction func findUserBtnTapped(sender: AnyObject) {
        let usrname = self.userNameTxtField.text!
        
        if usrname.characters.count > 12 || usrname.characters.count < 4 {
            print("DZ: Username Error")
            
            let alert = UIAlertController(title: "User Name Cannot Be Searched", message: "The user name needs to be between 4 and 12 charachers", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        DataService.ds.REF_USERS.queryOrderedByChild("userName").queryEqualToValue(usrname).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.exists() {
                print("DZ: snapshot exists for \(usrname)")
                self.userNameTxtField.text! = ""
                
                let alert = UIAlertController(title: "User Name Was Found", message: "Do you want to add them to your friends list", preferredStyle: UIAlertControllerStyle.Alert)
                
                let actionYes = UIAlertAction(title: "Yes", style: .Default) { (action) in
                    
                    print("DZ: In search for username, found a match and they want to add them to their friends")
                    // DZ - TODO - Add the to the friends list
                }
                
                let actionNo = UIAlertAction(title: "No", style: .Default) { (action) in
                    print("DZ: In search for username, found a match but they dont want to add them to their friends")
                }
                
                alert.addAction(actionYes)
                alert.addAction(actionNo)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertController(title: "Could Not Find User Name", message: "Please check your spelling and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        })
    }

    @IBAction func cancelBtnTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("searchToFeed", sender: nil)
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
