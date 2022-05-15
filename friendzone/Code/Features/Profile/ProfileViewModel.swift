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
    
    @Published var profilePicture: UIImage? {
        didSet {
            uploadImage()
        }
    }
    
    let storageRef = Storage.storage().reference()
    @Published var percentComplete: Float = 0.0
    @Published var profileCreated: Bool = false
    
    @Published var changedName = UserInfo(value: nil, newValue: nil, type: .name)
    @Published var changedBio = UserInfo(value: nil, newValue: nil, type: .bio)
    @Published var changedInsta = UserInfo(value: nil, newValue: nil, type: .insta)
    @Published var changedSnap = UserInfo(value: nil, newValue: nil, type: .snap)
    @Published var changedTikTok = UserInfo(value: nil, newValue: nil, type: .tiktok)
    
    @Published var bioHasChanged: Bool = false
    @Published var socialsHaveChanged: Bool = false
    
    @Published var infosHaveChanged: Bool = false
    
    var user: UserViewModel?
    
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
    
    func uploadImage() {
        guard let user = Auth.auth().currentUser else { return }
        
        guard let image = profilePicture, let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
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
    
    func updateInfo(completion: @escaping ((Bool) -> Void)) {
        var changedUser = user!
        
        if changedName.changed, let newName = changedName.newValue {
            changedUser.name = newName
        }
        if changedBio.changed, let newBio = changedBio.newValue {
            changedUser.bio = newBio
        }
        if changedSnap.changed {
            changedUser.snap = changedSnap.newValue
        }
        if changedInsta.changed  {
            changedUser.insta = changedInsta.newValue
        }
        if changedTikTok.changed {
            changedUser.tiktok = changedTikTok.newValue
        }

        FirebaseHandler.shared.uploadUserData(userId: changedUser.id, data: changedUser.toData()) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            case .success:
                print("done")
                completion(true)
            }
        }
    }
    
    init() {
        setupBindings()
    }
    
}

protocol ImagePicker {
    var profilePicture: UIImage? { get set }
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
