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

class YourZoneViewModel {
    
    var usersNearby: [UserViewModel] = [] {
        didSet {
            usersUpdated = true
        }
    }
    @Published var usersUpdated: Bool = false
    @Published var userInfo: FZUser?
    @Published var profileImage: UIImage?
    
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
                UserController.shared.loggedInUser = UserViewModel(model: info)
            }
        }
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
        guard let postalCode = postalCode, let country = country else { return }
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
        let resource = LoadableResource<FZUser>(path: [.collection(collectionName: "users")], firebaseConstraint: .containsMultipleValue(fieldName: "id", constraint: userIds))
        FirebaseHandler.shared.getData(resource: resource) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                self?.usersNearby = data.map { UserViewModel(model: $0) }
            }
        }
    }
    
    func updateLocation(postalCode: String, country: String) {
        guard let user = Auth.auth().currentUser else { return }
        FirebaseHandler.shared.updateLocation(postalCode: postalCode, country: country, userId: user.uid) { result in
            switch result {
            case .success:
                print("done")
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
