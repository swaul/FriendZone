//
//  ProfileViewModel.swift
//  friendzone
//
//  Created by Paul Kühnel on 07.05.22.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage
import friendzoneKit
import Combine

class ProfileViewModel: ImagePicker {
    
    @Published var profilePicture: UIImage?
    
    let storageRef = Storage.storage().reference()
    @Published var percentComplete: Float = 0.0
    @Published var profileComplete: Bool = true
    
    @Published var changedName = UserInfo(value: nil, newValue: "", type: .name)
    @Published var changedBio = UserInfo(value: nil, newValue: "", type: .bio)
    @Published var changedInsta = UserInfo(value: nil, newValue: "", type: .insta)
    @Published var changedSnap = UserInfo(value: nil, newValue: "", type: .snap)
    @Published var changedTikTok = UserInfo(value: nil, newValue: "", type: .tiktok)
    
    @Published var bioHasChanged: Bool = false
    @Published var socialsHaveChanged: Bool = false
    
    @Published var infosHaveChanged: Bool = false
    
    @Published var user: UserViewModel? {
        didSet {
            if let user = user, user.bio.isNilOrEmpty || user.profilePicture == nil {
                profileComplete = false
            }
        }
    }
    
    var localUser: LocalUser?
    
    var cancellablels = Set<AnyCancellable>()
    
    func setupBindings() {
        Publishers.CombineLatest($changedName, $changedBio).sink { (name, bio) in
            if name.changed || bio.changed {
                self.bioHasChanged = true
            } else {
                self.bioHasChanged = false
            }
        }.store(in: &cancellablels)
        
        Publishers.CombineLatest3($changedInsta, $changedTikTok, $changedSnap).sink { (insta, tiktok, snap) in
            if insta.changed || tiktok.changed || snap.changed {
                self.socialsHaveChanged = true
            } else {
                self.socialsHaveChanged = false
            }
        }.store(in: &cancellablels)
        
        Publishers.CombineLatest($bioHasChanged, $socialsHaveChanged).sink { (bio, socials) in
            if bio || socials {
                self.infosHaveChanged = true
            } else {
                self.infosHaveChanged = false
            }
        }.store(in: &cancellablels)
    }
    
    func updateProfilePicture(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        self.profilePicture = image
        uploadImage(image: image)
        
        guard let user = user else { return }
        user.model.profilePicture = user.id
        self.updateInfo(user: user) { _ in
            print("done")
        }
    }
    
    func uploadImage(image: UIImage) {
        guard let user = Auth.auth().currentUser else { return }
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
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
    
    func updateInfo(user: UserViewModel? = nil, completion: @escaping ((Bool) -> Void)) {
        let changedUser = user ?? self.user!
        
        if changedName.changed, let newName = changedName.newValue {
            changedUser.name = newName
        }
        if changedBio.changed, let newBio = changedBio.newValue {
            changedUser.bio = newBio
        }
        if changedSnap.changed {
            changedUser.snap = changedSnap.newValue
        }
        if changedInsta.changed {
            changedUser.insta = changedInsta.newValue
        }
        if changedTikTok.changed {
            changedUser.tiktok = changedTikTok.newValue
        }
        
        FirebaseHandler.shared.uploadUserData(userId: changedUser.id, data: changedUser.toData()) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            case .success:
                print("done")
                self?.saveUser(user: changedUser.model)
                completion(true)
            }
        }
    }
    
    func getLocalImage() -> UIImage? {
        guard profilePicture == nil, user?.profilePictureId != nil else { return nil }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("profilePic.png")
        
        do {
            return try UIImage(data: Data(contentsOf: url))
        } catch {
            return nil
        }
    }
    
    func getImage(id: String?, completion: ((Bool) -> Void)?) {
        guard let id = id else { return }
        if let image = getLocalImage() {
            profilePicture = image
        } else {
            Storage.storage().reference().child("images/\(id)").getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    guard let image = UIImage(data: data!) else { return }
                    self.profilePicture = image
                    if let data = image.pngData() {
                        // Create URL
                        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let url = documents.appendingPathComponent("profilePic.png")
                        
                        do {
                            try data.write(to: url)
                            completion?(true)
                        } catch {
                            print("Unable to Write Data to Disk (\(error))")
                            completion?(false)
                        }
                    }
                }
            }
        }
    }
    
    func removeImage() {
        guard let user = user, let profilePictureId = user.profilePictureId else { return }
        Storage.storage().reference().child("images/\(profilePictureId)").delete { [weak self] error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self?.profilePicture = nil
                user.profilePictureId = nil
                self?.updateInfo(user: user, completion: { [weak self] completed in
                    print("did delete profile picture", completed)
                })
                self?.saveUser(user: user.model)
                let manager = FileManager.default
                let documents = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let url = documents.appendingPathComponent("profilePic.png")
                let data = Data.init()
                do {
                    try data.write(to: url)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private var getUserCancellable: AnyCancellable?
    
    func getUser() {
        guard let user = Auth.auth().currentUser else { return }
        let storage = UserStorage.init(userId: user.uid)
        
        getUserCancellable = storage.loadState().sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                print("loaded")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, receiveValue: { [weak self] user in
            DispatchQueue.main.async {
                self?.localUser = user
                self?.user = UserViewModel(model: user.user)
            }
        })
    }
    
    private var saveUserCancellable: AnyCancellable?
    
    func saveUser(user: FZUser) {
        let storage = UserStorage(userId: user.id)
        saveUserCancellable?.cancel()
        let localUser: LocalUser
        if let savedLocalUser = self.localUser {
            localUser = savedLocalUser
            localUser.user = user
        } else {
            localUser = LocalUser(user: user)
        }
        saveUserCancellable = storage.saveState(LocalUser(user: user)).sink { completion in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished:
                print("saved")
            }
        } receiveValue: { _ in }
        
    }
    
    func resetData() {
        guard let user = Auth.auth().currentUser else { return }
        
        try! Auth.auth().signOut()
        
        let storage = UserStorage(userId: user.uid)
        storage.deleteState()
    }
    
    init() {
        print("################## PROFILE SCREEN CREATED")
        getUser()
        setupBindings()
    }
    
}

protocol ImagePicker {
    func updateProfilePicture(image: UIImage?)
}

class UserInfo: ObservableObject {
    
    var type: UserInfoType
    var value: String?
    var newValue: String?
    @Published var changed: Bool = false
    
    init(value: String?, newValue: String?, type: UserInfoType) {
        self.type = type
        guard let newValue = newValue, let value = value else {
            changed = false
            return
        }
        self.value = value
        self.newValue = newValue
        changed = newValue != value
    }
    
}

enum UserInfoType {
    case tiktok
    case insta
    case snap
    case name
    case bio
}
