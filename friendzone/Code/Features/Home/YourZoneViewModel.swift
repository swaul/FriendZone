//
//  YourZoneViewModel.swift
//  friendzone
//
//  Created by Paul Kühnel on 28.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import friendzoneKit
import FirebaseAuth
import FirebaseStorage
import UIKit
import Combine

class YourZoneViewModel {
    
    var usersNearby: [UserViewModel] = [] {
        didSet {
            usersUpdated = true
        }
    }
    @Published var usersUpdated: Bool = false
    @Published var userInfo: FZUser?
    @Published var profileImage: UIImage?
    @Published var isOffline: Bool = false {
        didSet {
            usersNearby.removeAll()
        }
    }
    
    func getUserInfo() {
        guard let user = Auth.auth().currentUser else { return }
        let resource = LoadableResource<FZUser>(path: [.collection(collectionName: "users")], firebaseConstraint: .containsMultipleValue(fieldName: "id", constraint: [user.uid]))
        FirebaseHandler.shared.getData(resource: resource) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                guard let info = data.first else { return }
                self.userInfo = info
                self.saveUser(user: info)
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
                self?.userInfo = user.user
            }
        })
    }
    
    private var saveUserCancellable: AnyCancellable?

    func saveUser(user: FZUser) {
        let storage = UserStorage(userId: user.id)
        saveUserCancellable?.cancel()
        saveUserCancellable = storage.saveState(LocalUser(user: user)).sink { completion in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished:
                print("saved")
            }
        } receiveValue: { _ in }
        
    }
    
    func getImage(id: String?) {
        guard let id = id else { return }

        Storage.storage().reference().child("images/\(id)").getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let image = UIImage(data: data!) else { return }
                self.profileImage = image
                UserController.shared.loggedInUser?.profilePicture = image
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
        }
    }
    
    func getNearbyUserIds(postalCode: String?, country: String?) {
        guard let postalCode = postalCode, let country = country, !isOffline else { return }
        let resource = LoadableResource<PostalCode>(path: [.collection(collectionName: "locations"), .document(documentName: country), .collection(collectionName: postalCode), .document(documentName: postalCode)])
        
        FirebaseHandler.shared.getData(resource: resource) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                guard let data = data.first else { return }
                self?.getNearbyUsers(userIds: data.users)
            }
        }
    }
    
    func getNearbyUsers(userIds: [String]) {
        guard let user = Auth.auth().currentUser else { return }
        var userIds = userIds
        userIds.remove(element: user.uid)
        guard !userIds.isEmpty else {
            return
        }
        let resource = LoadableResource<FZUser>(path: [.collection(collectionName: "users")], firebaseConstraint: .containsMultipleValue(fieldName: "id", constraint: userIds))
        FirebaseHandler.shared.getData(resource: resource) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                var users = data.map { UserViewModel(model: $0) }
                let defaults = UserDefaults.standard
                if let ignoredUsers = defaults.value(forKey: "ignoredUsers") as? [String: Date] {
                    for user in ignoredUsers {
                        users.removeAll(where: { $0.id == user.key })
                    }
                }
                self?.usersNearby = users
            }
        }
    }
    
    func updateLocation(postalCode: String, country: String) {
        guard let user = Auth.auth().currentUser, !isOffline else { return }

        let defaults = UserDefaults.standard
        if let lastLocation = defaults.value(forKey: "lastLocation") as? [String: Any] {
            let countr = lastLocation["country"] as! String
            let postal = lastLocation["postalCode"] as! String
            FirebaseHandler.shared.deleteLocation(userId: user.uid, postalCode: postal, country: countr) { result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    print("deleted")
                }
            }
        }
        FirebaseHandler.shared.updateLocation(postalCode: postalCode, country: country, userId: user.uid) { result in
            switch result {
            case .success:
                print("done")
                let data = [
                    "country": country,
                    "postalCode": postalCode
                ]
                defaults.set(data, forKey: "lastLocation")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

extension String: FirebaseDecodable {
    
    public init?(data: [String: Any]) {
        if let value = data.values.first as? String {
            self = value
            self.init()
        } else {
            self.init()
        }
    }
    
}
