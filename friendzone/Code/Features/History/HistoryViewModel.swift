//
//  HistoryViewModel.swift
//  friendzone
//
//  Created by Paul Kühnel on 12.05.22.
//

import Foundation
import friendzoneKit
import FirebaseAuth

class HistoryViewModel {
    
    @Published var savedUsers = [UserViewModel]()
    var savedUserIds = [String]() {
        didSet {
            getUsers(userIds: savedUserIds)
        }
    }
    
    func getUsers(userIds: [String]) {
        guard let user = Auth.auth().currentUser else { return }
        let resource = LoadableResource<FZUser>(path: [.collection(collectionName: "users")], firebaseConstraint: .containsMultipleValue(fieldName: "id", constraint: userIds))
        FirebaseHandler.shared.getData(resource: resource) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                self?.savedUsers = data.map { UserViewModel(model: $0) }
            }
        }
    }
    
    init() {
        retreiveSavedUsers()
    }
    
    func retreiveSavedUsers() {
        let defaults = UserDefaults.standard
        if let users = defaults.value(forKey: "savedUsers") as? [String: Date] {
            savedUserIds = users.map({ element in
                element.key
            })
        }
    }
    
}
