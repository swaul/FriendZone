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
    
    @Published var savedUsers = [UserViewModel]() {
        didSet {
            print("true")
            usersUpdated = true
        }
    }
    @Published var ignoredUsers = [UserViewModel]() {
        didSet {
            print("true")
            usersUpdated = true
        }
    }
    @Published var usersUpdated = false {
        didSet {
            if usersUpdated {
                viewModelState = .loaded
            }
        }
    }
    
    var savedUserIds = [String]() {
        didSet {
            getUsers(userIds: savedUserIds, ignored: false)
        }
    }
    
    var ignoredUserIds = [String]() {
        didSet {
            getUsers(userIds: ignoredUserIds, ignored: true)
        }
    }
    
    @Published var viewModelState: ViewModelState = .loading
    
    func getUsers(userIds: [String], ignored: Bool) {
        guard let user = Auth.auth().currentUser, !userIds.isEmpty else {
            savedUsers.removeAll()
            ignoredUsers.removeAll()
            return
        }
        let resource = LoadableResource<FZUser>(path: [.collection(collectionName: "users")], firebaseConstraint: .containsMultipleValue(fieldName: "id", constraint: userIds))
        FirebaseHandler.shared.getData(resource: resource) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                if ignored {
                    self?.ignoredUsers = data.map { UserViewModel(model: $0, ignored: true) }
                } else {
                    self?.savedUsers = data.map { UserViewModel(model: $0) }
                }
            }
        }
    }
    
    init() {
        retreiveSavedUsers()
    }
    
    func retreiveSavedUsers() {
        viewModelState = .loading
        let defaults = UserDefaults.standard
        if let users = defaults.value(forKey: "savedUsers") as? [String: Date] {
            savedUserIds = users.map({ element in
                element.key
            })
        }
        if let users = defaults.value(forKey: "ignoredUsers") as? [String: Date] {
            ignoredUserIds = users.map({ element in
                element.key
            })
        }
    }
    
}

enum ViewModelState {
    case loaded
    case loading
    case empty
    case error
}
