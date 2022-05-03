//
//  LoginViewModel.swift
//  friendzone
//
//  Created by Paul Kühnel on 29.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import FirebaseAuth

class LoginViewModel {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var onLogin: Bool = false
    @Published var error: String?
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.error = error.localizedDescription
            } else {
                print(result?.user)
                self?.onLogin = true
            }
        }
    }
    
}
