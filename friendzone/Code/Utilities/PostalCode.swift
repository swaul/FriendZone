//
//  PostalCode.swift
//  friendzone
//
//  Created by Paul Kühnel on 01.05.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import friendzoneKit

struct PostalCode: FirebaseDecodable {
    let users: [String]
    
    init?(data: [String : Any]) {
        self.users = data["users"] as! [String]
    }
}
