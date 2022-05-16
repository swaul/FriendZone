//
//  UserViewModel.swift
//  friendzone
//
//  Created by Paul Kühnel on 01.05.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import friendzoneKit
import FirebaseStorage

class UserViewModel {
    
    var model: FZUser!
    
    @Published var profilePicture: UIImage?
    
    var id: String {
        model.id
    }
    
    var score: Int {
        model.score
    }
    
    var email: String {
        model.email!
    }
    
    var ignored: Bool
    
    var name: String {
        get {
            model.name
        }
        set {
            model.name = newValue
        }
    }
    
    var bio: String {
        get {
            model.bio ?? ""
        }
        set {
            model.bio = newValue
        }
    }
    
    var tiktok: String? {
        get {
            model.tiktok
        }
        set {
            model.tiktok = newValue
        }
    }
    
    var insta: String? {
        get {
            model.instagram
        }
        set {
            model.instagram = newValue
        }
    }
    
    var snap: String? {
        get {
            model.snapchat
        }
        set {
            model.snapchat = newValue
        }
    }
    
    var images: [String] {
        model.images
    }
    
    var savedUsers = [String: Any]()
    
    init(model: FZUser, ignored: Bool = false) {
        self.model = model
        self.ignored = ignored
        loadImage(url: model.profilePicture)
    }
    
    func loadImage(url: String) {
        Storage.storage().reference().child("images/\(url)").getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let data = data else { return }
                if let image = UIImage(data: data) {
                    self.profilePicture = image
                }
            }
        }
    }
    
    func toData() -> [String: Any] {
        let data: [String: Any] = [
            "id": id,
            "profilePicture": model.profilePicture,
            "email": email,
            "name": name,
            "bio": bio,
            "score": score,
            "instagram": insta ?? "",
            "tiktok": tiktok ?? "",
            "snapchat": snap ?? ""
        ]
        
        return data
    }
    
}
