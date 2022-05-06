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
        guard value.count > 7 else { return ValidationInfo(isValid: false, errorMessage: "Gib mindestens 7 Zeichen an") }
        return .valid
    }, formatter: { value in
        return value?.trimmingCharacters(in: .whitespacesAndNewlines)
    })
    
    @Published var onLogin: Bool = false
    @Published var passwordError: String? {
        didSet {
            print(passwordError)
        }
    }
    @Published var emailError: String?
    
    func login() {
        Auth.auth().signIn(withEmail: email.value!, password: password.value!) { [weak self] result, error in
            if let error = error {
                self?.passwordError = error.localizedDescription
            } else {
                self?.onLogin = true
            }
        }
    }
    
}
