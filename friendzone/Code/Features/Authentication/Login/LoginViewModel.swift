//
//  LoginViewModel.swift
//  friendzone
//
//  Created by Paul Kühnel on 29.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import FirebaseAuth
import KeychainAccess

class LoginViewModel {
    
    @Published var email = ValidatedText(value: nil, validation: { value in
        guard let value = value else { return .initial }
        guard !value.isEmpty else { return ValidationInfo(isValid: false, errorMessage: "Bitte gib deine E-Mail an")
        }
        guard value.contains("@"), value.contains("."), value.count > 3 else { return ValidationInfo(isValid: false, errorMessage: "Gültige E-Mail angeben") }
        return .valid
    }, formatter: { value in
        return value?.trimmingCharacters(in: .whitespacesAndNewlines)
    })

    @Published var password = ValidatedText(value: nil, validation: { value in
        guard let value = value else { return .initial }
        guard !value.isEmpty else { return ValidationInfo(isValid: false, errorMessage: "Bitte gib dein Passwort ein") }
        guard value.count > 7 else { return ValidationInfo(isValid: false, errorMessage: "Gib mindestens 8 Zeichen an") }
        return .valid
    }, formatter: { value in
        return value?.trimmingCharacters(in: .whitespacesAndNewlines)
    })
    
    @Published var onLogin: Bool = false
    @Published var passwordError: String?
    @Published var emailError: String?
    
    @Published var shake: Bool = false
    
    func login() {
        Auth.auth().signIn(withEmail: email.value!, password: password.value!) { [weak self] result, error in
            if let error = error {
                self?.shake = true
                self?.passwordError = error.localizedDescription
            } else {
                guard let result = result, let self = self else { return }
                let defaults = UserDefaults.standard
                defaults.setValue(result.credential, forKey: "credentials")
                
                let keychain = Keychain(service: "addzone")
                keychain[self.email.value!] = self.password.value
                
                self.onLogin = true
            }
        }
    }
    
    func getKeychainData() {
        let keychain = Keychain(service: "addzone")
        
    }
    
}
