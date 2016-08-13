//
//  ProfileVC.swift
//  sosocialapp
//
//  Created by David Zielski on 8/11/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profileImg: CircleViewWithBorder!
    @IBOutlet weak var profileName: UITextField!
    
    var profileImagePicker: UIImagePickerController!
    var imageSelected = false

    var startingProfileName = ""

    //*****************************************************************
    // MARK: - viewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImagePicker = UIImagePickerController()
        profileImagePicker.allowsEditing = true
        profileImagePicker.delegate = self
        
        profileName.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            self.profileName.text = snapshot.value!["userName"] as? String
            
            self.startingProfileName = self.profileName.text!
            
            // see if there is a image that exists and if so lets use it
            
            if let _ = snapshot.value!["imageURL"]! {
                
                self.imageSelected = true
                
                let profileImage = snapshot.value!["imageURL"] as? String
                
                if let img = FeedVC.profileImageCache.objectForKey(profileImage!) {
                    self.profileImg.image = img as? UIImage
                    
                } else {
                    FIRStorage.storage().referenceForURL(profileImage!).dataWithMaxSize(2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("DZ: Unable to download profile image from Firebase storage")
                        } else {
                            print("DZ: Downloaded profile image from Firebase storage")
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                    self.profileImg.image = img
                                    FeedVC.profileImageCache.setObject(img, forKey: profileImage!)
                                }
                            }
                        }
                    })
                }
            }
            
        })
    }
    
    //*****************************************************************
    // MARK: - Buttons and Actions
    //*****************************************************************

    @IBAction func saveBtnTapped(sender: AnyObject) {
        let usrname = self.profileName.text!
        var checkForDups = true
        
        if usrname.characters.count > 12 || usrname.characters.count < 4 {
            print("DZ: User Name error")
            
            let alert = UIAlertController(title: "User Name Cannot Be Used", message: "Your user name needs to be between 4 and 12 charachers", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // if this is the user, no need to check for dup name
        if startingProfileName == usrname {
            checkForDups = false
        }
        
        DataService.ds.REF_USERS.queryOrderedByChild("userName").queryEqualToValue(usrname).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if checkForDups && snapshot.exists() {
                print("DZ: snapshot exists for \(usrname)")
                
                let alert = UIAlertController(title: "Duplicate User Name Found", message: "Your User Name needs to be unique like you are, please think of another User Name to use.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
                
            }
            else {
                print("DZ: snapshot doesnt exist for \(usrname)")
                
                guard let userName = self.profileName.text where userName != "" else {
                    print("DZ: User Name must be entered")
                    
                    let alert = UIAlertController(title: "User Name Is Empty", message: "Your User Name needs to be present like you are, please think of a User Name to use.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
                
                guard let img = self.profileImg.image where self.imageSelected == true else {
                    print("DZ: Image must be selected")
                    let alert = UIAlertController(title: "Profile Picture Is Empty", message: "Your Profile Picture needs to be present like you are, please add a picture of yourself.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
                
                if let imgData = UIImageJPEGRepresentation(img, 0.2) {
                    
                    let imgUid = NSUUID().UUIDString
                    let metadata = FIRStorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    DataService.ds.REF_PROFILE_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { metadata, error in
                        if error != nil {
                            print("DZ: Unabel to upload image to Firebase")
                        } else {
                            print("DZ: Successfully uploaded image to Firebase")
                            self.imageSelected = false
                            let downloadURL = metadata?.downloadURL()?.absoluteString
                            if let url = downloadURL {
                                self.postToFirebase(url)
                            }
                            
                            // flush cache as we changed a profile image
                            FeedVC.profileImageCache.removeAllObjects()
                            self.performSegueWithIdentifier("profileToFeed", sender: nil)
                        }
                    }
                }
            }
        })
        //    { (error) in
        //      print("DZ: Error - \(error.localizedDescription)")
        //    }
    
    
    }

    @IBAction func cancelBtnTapped(sender: AnyObject) {
        // DZ - TODO - right now a back door exists to allow users that come here for the first
        // time and do not set a profile image or name and hit cancel - they will go to the
        // feed without setting a profile. Have to think whether to let them see the feed
        // but when they try and post to thr feed send them back here to set up a profile or
        // force them to stay here and set up profile first. If this second choice is selected
        // then maybe hide cancel button until a profile is set up or was already set up
        
        self.performSegueWithIdentifier("profileToFeed", sender: nil)
        
    
    }
    
    @IBAction func clkImgBtnTapped(sender: AnyObject) {
        self.presentViewController(profileImagePicker, animated: true, completion: nil)
        
    }

    @IBAction func logoutBtnTapped(sender: AnyObject) {
        let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        print("DZ: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        self.performSegueWithIdentifier("profileToSignIn", sender: nil)
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
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImg.image = image
            imageSelected = true
        } else {
            print("DZ: A valid image was not selected")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func postToFirebase (imgURL: String) {
        
        let profile: Dictionary<String, AnyObject> = [
            "userName": profileName.text!,
            "imageURL": imgURL,
            ]
        
        let firebasePost = DataService.ds.REF_USER_CURRENT
        firebasePost.setValue(profile)
        
        imageSelected = false
    }
   
    
    
    
    
    
    

}
