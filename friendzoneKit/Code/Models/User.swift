//
//  User.swift
//  friendzoneKit
//
//  Created by Paul Kühnel on 28.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation

public struct FZUser: FirebaseDecodable {
    
    public var id: String
    public var name: String
    public var profilePicture: String
    public var email: String?
    public var snapchat: String?
    public var instagram: String?
    public var tiktok: String?
    public var bio: String?
    public var score: Int
    public var images: [String]
    public var postalCode: String?
    
    public init(id: String, name: String, profilePicture: String, snapchat: String?, instagram: String?, tiktok: String?, bio: String?, score: Int, images: [String], postalCode: String) {
        self.id = id
        self.name = name
        self.profilePicture = profilePicture
        self.snapchat = snapchat
        self.instagram = instagram
        self.tiktok = tiktok
        self.bio = bio
        self.score = score
        self.images = images
        self.email = nil
        self.postalCode = postalCode
    }
    
    public init?(data: [String: Any]) {
        self.id = data["id"] as! String
        self.name = data["name"] as! String
        self.profilePicture = data["profilePicture"] as! String
        self.bio = data["bio"] as! String
        self.email = data["email"] as! String
        if let snapchat = data["snapchat"] as? String {
            self.snapchat = snapchat
        } else {
            self.snapchat = nil
        }
        if let instagram = data["instagram"] as? String {
            self.instagram = instagram
        } else {
            self.instagram = nil
        }
        if let tiktok = data["tiktok"] as? String {
            self.tiktok = tiktok
        } else {
            self.tiktok = nil
        }
        self.score = data["score"] as! Int
        self.images = []
        if let postalCode = data["postalCode"] as? String {
            self.postalCode = postalCode
        } else {
            self.postalCode = nil
        }
    }
    
}
