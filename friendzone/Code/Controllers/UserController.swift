//
//  UserController.swift
//  friendzone
//
//  Created by Paul Kühnel on 08.05.22.
//

import Foundation
import FirebaseAuth

class UserController {
    
    static let shared = UserController()
    
    @Published var loggedInUser: UserViewModel?
    
}
