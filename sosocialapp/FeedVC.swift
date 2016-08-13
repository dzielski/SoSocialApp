//
//  FeedVC.swift
//  sosocialapp
//
//  Created by David Zielski on 8/11/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyFieldTextBox!
    @IBOutlet weak var topFeedType: UILabel!
    @IBOutlet weak var allFeedBarBtnView: UIBarButtonItem!
    @IBOutlet weak var likeFeedBarBtnFeedView: UIBarButtonItem!
    @IBOutlet weak var friendFeedBarBtnView: UIBarButtonItem!
    @IBOutlet weak var userFeedBarBtnView: UIBarButtonItem!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
//    static var imageCache: NSCache = NSCache()
//    static var profileImageCache: NSCache = NSCache()
    static var imageCache = NSCache()
    static var profileImageCache = NSCache()
    
    // DZ Todo - fix this cheesy method to prevent camera image saving to database
    var imageSelected = false
    
    //*****************************************************************
    // MARK: - viewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FeedVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        captionField.delegate = self
        
        // setup a redraw feed notification we can call from table cell
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedVC.redrawFeedTable), name: "feedRedrawName", object: nil)
        
        redrawFeedTable()
    }
    

    // If we get a memory warning we should dump cache and try and recover
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        FeedVC.imageCache.removeAllObjects()
        FeedVC.profileImageCache.removeAllObjects()
    }

    //*****************************************************************
    // MARK: - Table View Functions
    //*****************************************************************
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DZ - In numberOfRowsInSection - \(posts.count)")
        
        if posts.count == 0 {
        
            let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            messageLabel.text = "There are no posts to show you in this feed. Please select another feed type below."
            messageLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "Avenir", size: 20)
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = .None
            
            return 0
        } else {
            return posts.count
        }
    }
    
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 1
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
       
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {

           if let img = FeedVC.imageCache.objectForKey(post.imageURL) {
                cell.configureCell(post, img: img as? UIImage)
            } else {
                cell.configureCell(post)
            }
            return cell
        
        }
        else {
            //should never happen
            return PostCell()
        }

    }

    //*****************************************************************
    // MARK: - Buttons and Actions
    //*****************************************************************


    
    @IBAction func cameraIconTapped(sender: AnyObject) {
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

 
    @IBAction func postBtnTapped(sender: AnyObject) {
        guard let caption = captionField.text where caption != "" else {
            print("DZ: Caption must be entered")
            let alert = UIAlertController(title: "Caption Is Empty", message: "You need to add a caption for a post. Please enter one now.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.captionField.becomeFirstResponder();
            return
        }
        
        dismissKeyboard()
        
        guard let img = imageAdd.image where imageSelected == true else {
            let alert = UIAlertController(title: "Picture Is Missing", message: "You need to add an image to post. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            print("DZ: Image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
        
            let imgUid = NSUUID().UUIDString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { metadata, error in
                if error != nil {
                    print("DZ: Unable to upload image to Firebase")
                    let alert = UIAlertController(title: "Error Saving Post", message: "Something went wrong saving your post to the database.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        print("DZ: Successfully uploaded image to Firebase")
                        self.imageSelected = false
                        let downloadURL = metadata?.downloadURL()?.absoluteString
                        if let url = downloadURL {
                            self.postToFirebase(url, imgID: imgUid)
                    }
                }
            }
        }
        
    }
    
    
    @IBAction func profileBtnTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showProfile", sender: nil)
    }
    
    @IBAction func allFeedBtnTapped(sender: AnyObject) {
        // only do if is not the all feed
        if FeedType.ft.feedTypeToShow != FeedType.FeedTypeEnum.allFeed {
            FeedType.ft.feedTypeToShow = FeedType.FeedTypeEnum.allFeed
            redrawFeedTable()
        }
    }
    
    @IBAction func likeFeedBtnTapped(sender: AnyObject) {
        // only do if is not the like feed
        if FeedType.ft.feedTypeToShow != FeedType.FeedTypeEnum.likeFeed {
            FeedType.ft.feedTypeToShow = FeedType.FeedTypeEnum.likeFeed
            redrawFeedTable()
        }
    }
    
    @IBAction func friendFeedBtnTapped(sender: AnyObject) {
        // only do if is not the friend feed
        if FeedType.ft.feedTypeToShow != FeedType.FeedTypeEnum.friendFeed {
            FeedType.ft.feedTypeToShow = FeedType.FeedTypeEnum.friendFeed
            redrawFeedTable()
        }
    }
    
    @IBAction func userFeedBtnTapped(sender: AnyObject) {
        // only do if is not the friend feed
        if FeedType.ft.feedTypeToShow != FeedType.FeedTypeEnum.userFeed {
            FeedType.ft.feedTypeToShow = FeedType.FeedTypeEnum.userFeed
            redrawFeedTable()
        }
    }

    @IBAction func searchBtnTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("searchForUser", sender: nil)
    }
    
    
    @IBAction func helpBtnTapped(sender: AnyObject) {
    let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("sbPopUpID") as! PopUpVC
        
    self.addChildViewController(popOverVC)
    popOverVC.view.frame = self.view.frame
    self.view.addSubview(popOverVC.view)
    popOverVC.didMoveToParentViewController(self)
    
    }
    

    //*****************************************************************
    // MARK: - Helper Functions
    //*****************************************************************

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
        
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
//            self.captionField.becomeFirstResponder();
        } else {
            print("DZ: A valid image was not selected")
        }
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func postToFirebase (imgURL: String, imgID: String) {
        
        let uid = KeychainWrapper.stringForKey(KEY_UID)
        
        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text!,
            "imageURL": imgURL,
            "likes": 0,
            "postOwner": uid!,
            "imgID": imgID,
            "date": FIRServerValue.timestamp()
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        let newPostRef = DataService.ds.REF_USER_CURRENT.child("postList").child(firebasePost.key)
        newPostRef.setValue(true)
        
        print("DZ: New Post ID - \(firebasePost.key)")
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        redrawFeedTable()
    }
    
    func redrawFeedTable() {
        
        self.posts = []
        tableView.reloadData()
        
        switch FeedType.ft.feedTypeToShow {
            
        case .likeFeed:
            
            allFeedBarBtnView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            likeFeedBarBtnFeedView.tintColor = UIColor(red: 211.0/255.0, green: 9.0/255.0, blue: 21.0/255.0, alpha: 1.0)
            friendFeedBarBtnView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            userFeedBarBtnView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            
            topFeedType.text = "Liked Posts"
            
            // first find the like list of the current user
            // get the liked posts
            // sort the posts
            // display
            
            DataService.ds.REF_USER_CURRENT.child("likeList").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for child in snapshots {
                        print("DZ: Liked Post = \(child.key)")
                        
                        DataService.ds.REF_POSTS.child(child.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                                let id = snapshot.key
                                let post = Post(postID: id, postData: postDict)
                                self.posts.append(post)
                                print("DZ: Appending Like Post = \(id)")
                            }
                            self.posts.sortInPlace({$0.date > $1.date})
                            self.tableView.reloadData()
                        })
                        
                    }
                }
            })
            
        case .allFeed:
            
            allFeedBarBtnView.tintColor = UIColor(red: 247.0/255.0, green: 143.0/255.0, blue: 37.0/255.0, alpha: 1.0)
            likeFeedBarBtnFeedView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            friendFeedBarBtnView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            userFeedBarBtnView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            
            topFeedType.text = "All Posts"
            
            // get the user id because will not show own users posts in the all feed
            let uid = KeychainWrapper.stringForKey(KEY_UID)
            
            DataService.ds.REF_POSTS.queryOrderedByChild("date").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            let id = snap.key
                            let post = Post(postID: id, postData: postDict)
                            
                            // if this is not the currnet users post, then add it
                            if uid != post.postOwner {
                                self.posts.append(post)
                            }
                        }
                    }
                }
                self.posts.sortInPlace({ $0.date > $1.date })
                self.tableView.reloadData()
            })
            
        case .friendFeed:
            
            allFeedBarBtnView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            likeFeedBarBtnFeedView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            friendFeedBarBtnView.tintColor = UIColor(red: 69.0/255.0, green: 45.0/255.0, blue: 157.0/255.0, alpha: 1.0)
            userFeedBarBtnView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            
            topFeedType.text = "Friends Posts"
            
            // first find the friend list of the current user
            // next read each friends post list
            // get the friends posts
            // sort the posts
            // display
            
            DataService.ds.REF_USER_CURRENT.child("friendList").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for child in snapshots {
                        print("DZ: Friend = \(child.key)")
                        
                        
                        DataService.ds.REF_USERS.child(child.key).child("postList").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                for child in snapshots {
                                    print("DZ: Friend's Post = \(child.key)")
                                    
                                    DataService.ds.REF_POSTS.child(child.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                        if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                                            let id = snapshot.key
                                            let post = Post(postID: id, postData: postDict)
                                            self.posts.append(post)
                                            print("DZ: Appending Friend's Post = \(id)")
                                        }
                                        self.posts.sortInPlace({$0.date > $1.date})
                                        self.tableView.reloadData()
                                    })
                                }
                            }
                        })
                    }
                }
            })
            
            break
            
        case .userFeed:
            
            allFeedBarBtnView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            likeFeedBarBtnFeedView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            friendFeedBarBtnView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            userFeedBarBtnView.tintColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            
            topFeedType.text = "Your Posts"
            
            // first find the post list of the current user
            // get the posts
            // sort the posts
            // display
            
            DataService.ds.REF_USER_CURRENT.child("postList").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for child in snapshots {
                        print("DZ: Liked Post = \(child.key)")
                        
                        DataService.ds.REF_POSTS.child(child.key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                                let id = snapshot.key
                                let post = Post(postID: id, postData: postDict)
                                self.posts.append(post)
                                print("DZ: Appending Like Post = \(id)")
                            }
                            self.posts.sortInPlace({$0.date > $1.date})
                            self.tableView.reloadData()
                        })
                        
                    }
                }
            })
            
        }
        
        
    }

}
