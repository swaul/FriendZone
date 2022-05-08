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
    
    let model: FZUser!
    
    @Published var profilePicture: UIImage?
    
    var score: Int {
        model.score
    }
    var name: String {
        model.name
    }
    var bio: String {
        model.bio ?? ""
    }
    
    init(model: FZUser) {
        self.model = model
        loadImage(url: model.profilePicture)
    }
    
    func loadImage(url: String) {
        Storage.storage().reference().child("images/\(url).png").getData(maxSize: 10 * 1024 * 1024) { data, error in
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
    
}
