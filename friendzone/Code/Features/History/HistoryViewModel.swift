//
//  HistoryViewModel.swift
//  friendzone
//
//  Created by Paul Kühnel on 12.05.22.
//

import Foundation
import friendzoneKit
import FirebaseAuth
import Combine

class HistoryViewModel {
    
    @Published var savedUsers = [UserViewModel]() {
        didSet {
            usersUpdated = true
        }
    }
    @Published var ignoredUsers = [UserViewModel]() {
        didSet {
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
            print("saved users: \(savedUserIds)")
            getUsers(userIds: savedUserIds, ignored: false)
        }
    }
    
    var ignoredUserIds = [String]() {
        didSet {
            print("ignored users: \(ignoredUserIds)")
            getUsers(userIds: ignoredUserIds, ignored: true)
        }
    }
    
    @Published var viewModelState: ViewModelState = .loading
    
    var user: FZUser?
    
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
                self?.viewModelState = .loaded
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
        getUser()
    }
    
    private var getUserCancellable: AnyCancellable?
    
    func getUser() {
        guard let user = Auth.auth().currentUser else { return }
        let storage = UserStorage.init(userId: user.uid)
        getUserCancellable?.cancel()
        
        getUserCancellable = storage.loadState().sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                print("loaded")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, receiveValue: { [weak self] user in
            DispatchQueue.main.async {
                self?.user = user.user
                self?.ignoredUserIds = user.ignoredUserIds
                self?.savedUserIds = user.savedUserIds
            }
        })
    }
    
    private var saveUserCancellable: AnyCancellable?
    
    func removeUser(userId: String, fromIgnored: Bool) {
        guard let user = user else { return }
        let storage = UserStorage(userId: user.id)
        let localUser = LocalUser(user: user)
        saveUserCancellable?.cancel()

        if fromIgnored {
            localUser.ignoredUserIds.remove(element: userId)
        } else {
            localUser.savedUserIds.remove(element: userId)
        }
        
        saveUserCancellable = storage.saveState(localUser).sink { completion in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished:
                print("removed \(userId)")
                self.ignoredUsers.removeAll()
                self.savedUsers.removeAll()
                self.retreiveSavedUsers()
            }
        } receiveValue: { _ in }
        
    }
    
}

enum ViewModelState {
    case loaded
    case loading
    case empty
    case error
}
