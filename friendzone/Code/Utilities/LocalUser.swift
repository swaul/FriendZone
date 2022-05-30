//
//  LocalUser.swift
//  friendzoneKit
//
//  Created by Paul Kühnel on 19.05.22.
//

import Foundation
import friendzoneKit

class LocalUser: Codable {

    let user: FZUser
    
    var ignoredUserIds = [String]()
    var savedUserIds = [String]()
    
    init(user: FZUser) {
        self.user = user
    }
}
