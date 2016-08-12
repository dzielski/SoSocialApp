//
//  Post.swift
//  sosocialapp
//
//  Created by David Zielski on 8/11/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import Foundation
import Firebase


class Post {
    
    private var _caption: String!
    private var _imageURL: String!
    private var _likes: Int!
    private var _postID: String!
    private var _postOwner: String!
    private var _imgID: String!
    private var _date: Int!
    private var _likeUsers: String!
    
    private var _postRef: FIRDatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageURL: String {
        return _imageURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var postID: String {
        return _postID
    }
    
    var postOwner: String {
        return _postOwner
    }
    
    var imgID: String {
        return _imgID
    }
    
    var date: Int {
        return _date
    }
    
    var likeUsers: String {
        return _likeUsers
    }
    
    init(caption: String, imageURL: String, likes: Int, postOwner: String, imgID: String, date: Int, likeUsers: String) {
        self._caption = caption
        self._imageURL = imageURL
        self._likes = likes
        self._postOwner = postOwner
        self._imgID = imgID
        self._date = date
        self._likeUsers = likeUsers
        
    }
    
    
    init(postID: String, postData: Dictionary<String, AnyObject>) {
        
        self._postID = postID
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageURL = postData["imageURL"] as? String {
            self._imageURL = imageURL
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let postOwner = postData["postOwner"] as? String {
            self._postOwner = postOwner
        }
        
        if let imgID = postData["imgID"] as? String {
            self._imgID = imgID
        }
        
        if let date = postData["date"] as? Int {
            self._date = date
        }
        
        if let likeUsers = postData["likeUsers"] as? String {
            self._likeUsers = likeUsers
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postID)
        
        
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
        
        
    }
    
    
    
}
