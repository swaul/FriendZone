//
//  RegisterViewModel.swift
//  friendzone
//
//  Created by Paul Kühnel on 30.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseAnalytics
import Combine
import friendzoneKit

class RegisterViewModel {
    
    @Published var email = ValidatedText(value: nil, validation: { value in
        guard let value = value else { return .initial }
        guard !value.isEmpty else { return ValidationInfo(isValid: false, errorMessage: "Bitte gib eine E-Mail an") }
        guard value.contains("@"), value.contains("."), value.count > 3 else { return ValidationInfo(isValid: false, errorMessage: "Gültige E-Mail angeben") }
        return .valid
    }, formatter: { value in
        return value?.trimmingCharacters(in: .whitespacesAndNewlines)
    })
    
    @Published var name = ValidatedText(value: nil, validation: { value in
        guard let value = value else { return .initial }
        guard !value.isEmpty else { return ValidationInfo(isValid: false, errorMessage: "Bitte gib deinen Namen an") }
        guard value.count > 3 else { return ValidationInfo(isValid: false, errorMessage: "Gib mindestens 3 Buchstaben an") }
        return .valid
    }, formatter: { value in
        return value?.trimmingCharacters(in: .whitespacesAndNewlines)
    })
    
    @Published var phoneNumber = ValidatedText(value: nil, validation: { value in
        guard let value = value else { return .initial }
        guard !value.isEmpty else { return ValidationInfo(isValid: false, errorMessage: "Bitte gib deine Handynummer an") }
        guard value.count > 3 else { return ValidationInfo(isValid: false, errorMessage: "Gib eine gültige Nummer ein") }
        return .valid
    }, formatter: { value in
        return value?.trimmingCharacters(in: .whitespacesAndNewlines)
    })
    
    @Published var profilePicture: UIImage?
    @Published var bio: String?
    
    @Published var newPassword = ValidatedText(value: nil, validation: { value in
        guard let value = value else { return .initial }
        guard !value.isEmpty else { return ValidationInfo(isValid: false, errorMessage: "Bitte gib ein Passwort ein") }
        guard value.count > 7 else { return ValidationInfo(isValid: false, errorMessage: "Gib mindestens 8 Zeichen an") }
        return .valid
    }, formatter: { value in
        return value?.trimmingCharacters(in: .whitespacesAndNewlines)
    })
    
    @Published var confirmPasswordValid: Bool = false
    
    @Published var usernameValid: Bool = false
    @Published var emailStepValid: Bool = false
    @Published var profileStepValid: Bool = true
    @Published var passwordStepValid: Bool = false
    
    @Published var instagramValid: Bool?
    @Published var tiktokValid: Bool?
    @Published var snapchatValid: Bool?
    
    @Published var agreedToTerms: Bool = false
        
    @Published var instagram: String? {
        didSet {
            guard let instagram = instagram, let url = URL(string: "https://instagram.com/\(instagram)/") else {
                return
            }
            validityTimer(url: url)
        }
    }
    
    @Published var tiktok: String? {
        didSet {
            guard let tiktok = tiktok, let url = URL(string: "https://tiktok.com/@\(tiktok)/") else {
                return
            }
            validityTimer(url: url)
        }
    }
    
    @Published var snapchat: String?
    @Published var percentComplete: Float = 0.0
    @Published var profileCreated: Bool = false
    @Published var userCreated: Bool?
    
    let storageRef = Storage.storage().reference()
    
    init() {
        setupBindings()
    }
    
    var cancellabels = Set<AnyCancellable>()
    
    var instaTimer: Timer?
    var tiktokTimer: Timer?
    
    func validityTimer(url: URL) {
        instaTimer?.invalidate()
        print("timer started")
        instaTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
            self.checkValidity(url: url)
        }
    }
    
    func validityTimerTikTok(url: URL) {
        tiktokTimer?.invalidate()
        print("timer started")
        tiktokTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
            self.checkValidity(url: url)
        }
    }
    
    func checkValidity(url: URL) {
        print("now")
        let task = URLSession.shared.dataTask(with: url) { _, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            if httpResponse.statusCode == 404 {
                DispatchQueue.main.async {
                    if url.absoluteString.contains("tiktok") {
                        self.tiktokValid = false
                    } else {
                        self.instagramValid = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if url.absoluteString.contains("tiktok") {
                        self.tiktokValid = true
                    } else {
                        self.instagramValid = true
                    }
                }
            }
        }
        task.resume()
    }
    
    func setupBindings() {
        name.$validation.sink { [weak self] name in
            if name == .valid {
                self?.usernameValid = true
            } else {
                self?.usernameValid = false
            }
        }.store(in: &cancellabels)
        
        email.$validation.sink { [weak self] email in
            if email == .valid {
                self?.emailStepValid = true
            } else {
                self?.emailStepValid = false
            }
        }.store(in: &cancellabels)
        
        Publishers.CombineLatest(newPassword.$validation, $confirmPasswordValid).sink { [weak self] (password, passwordValid) in
            if password == .valid && passwordValid {
                self?.passwordStepValid = true
            } else {
                self?.passwordStepValid = false
            }
        }.store(in: &cancellabels)
    }
    
    func checkPassword(confirmedPassword: String) {
        guard let password = newPassword.value else { return confirmPasswordValid = false }
        if password == confirmedPassword {
            confirmPasswordValid = true
        } else {
            confirmPasswordValid = false
        }
    }
    
    func registerUser() {
        Auth.auth().createUser(withEmail: email.value!, password: newPassword.value!) { [weak self] authResult, error in
            if let error = error {
                print(error.localizedDescription)
                self?.userCreated = false
            } else {
                guard let result = authResult else { return }
                if !result.user.isEmailVerified {
                    result.user.sendEmailVerification(completion: { error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            self?.userCreated = true
                            print("logged in")
                            print("email sent")
                        }
                    })
                } else {
                    print("logged in")
                    print("verified")
                    self?.userCreated = true
                }
                
            }
        }
    }
    
    func isEmailInUse(completion: ((Bool) -> Void)?) {
        guard let email = email.value, self.email.validation == .valid else { return }
        Auth.auth().fetchSignInMethods(forEmail: email, completion: { (providers, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let providers = providers {
                    if providers.isEmpty {
                        completion?(false)
                    } else {
                        completion?(true)
                    }
                } else if providers == nil {
                    completion?(false)
                }
            })
    }
    
    func checkVerification(completion: ((Bool) -> Void)?) {
        guard let user = Auth.auth().currentUser else {
            completion?(false)
            return
        }
        user.reload { error in
            if let error = error {
                completion?(false)
                print(error.localizedDescription)
            } else {
                if user.isEmailVerified {
                    print("YOU DID IT YOU CRAZY SON OF")
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        }

    }
    
    public func uploadImage() {
        guard let user = Auth.auth().currentUser else { return }
        
        guard let image = profilePicture, let imageData = image.jpegData(compressionQuality: 0.5) else {
            uploadUserInfo(userId: user.uid)
            return
        }
        
        let userId = user.uid
        let imagesRef = storageRef.child("images/\(userId)")
        
        let uploadTask = imagesRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print(metadata?.path)
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let currentValue = (100.0 * Float(snapshot.progress!.completedUnitCount) / Float(snapshot.progress!.totalUnitCount))
            self.percentComplete = currentValue
        }
        
        uploadTask.observe(.success) { [weak self] snapshot in
            // Upload completed successfully
            print("image uploaded to", snapshot.reference)
            self?.uploadUserInfo(userId: userId)
            uploadTask.removeAllObservers()
        }
        
        uploadTask.observe(.failure) { snapshot in
            print(snapshot.error)
        }
        
        if let data = image.pngData() {
            // Create URL
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent("profilePic.png")
            
            do {
                try data.write(to: url)
            } catch {
                print("Unable to Write Data to Disk (\(error))")
            }
        }
    }
    
    func toData() -> [String: Any] {
        let data: [String: Any] = [
            "email": email.value!,
            "name": name.value!,
            "bio": bio ?? "",
            "score": 0,
            "instagram": instagram ?? "",
            "tiktok": tiktok ?? "",
            "snapchat": snapchat ?? ""
        ]
        
        return data
    }
    
    func uploadUserInfo(userId: String) {
        var data = toData()
        if profilePicture != nil {
            data["profilePicture"] = userId
        } else {
            data["profilePicture"] = ""
        }
        data["id"] = userId
        FirebaseHandler.shared.uploadUserData(userId: userId, data: data) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(()):
                print("user created")
                self?.profileCreated = true
            }
        }
    }
}

extension Optional where Wrapped == String {
    
    var isNilOrEmpty: Bool {
        guard let value = self else { return true }
        return value.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }
    
}
