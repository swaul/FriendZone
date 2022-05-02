//
//  User.swift
//  friendzoneKit
//
//  Created by Paul Kühnel on 28.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation

public struct FZUser: FirebaseDecodable {
    
    public let name: String
    public let profilePicture: String
    public let email: String?
    public let snapchat: String?
    public let instagram: String?
    public let tiktok: String?
    public let bio: String?
    public let score: Int
    public let images: [String]
    
    public init(name: String, profilePicture: String, snapchat: String?, instagram: String?, tiktok: String?, bio: String?, score: Int, images: [String]) {
        self.name = name
        self.profilePicture = profilePicture
        self.snapchat = snapchat
        self.instagram = instagram
        self.tiktok = tiktok
        self.bio = bio
        self.score = score
        self.images = images
        self.email = nil
    }
    
    public init?(data: [String: Any]) {
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
    }
    
}
