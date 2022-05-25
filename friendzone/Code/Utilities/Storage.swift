//
//  Storage.swift
//  friendzone
//
//  Created by Paul Kühnel on 19.05.22.
//

import Foundation
import Combine
import friendzoneKit

class UserStorage {
    private let userId: String
    private let fileAccess: FileAccess
    private let filename: String = "userStorage"
    
    init(userId: String) {
        self.userId = userId
        self.fileAccess = .init(folderName: "\(userId).\(filename)")
    }
    
    func loadState() -> AnyPublisher<LocalUser, LoadingError> {
        return fileAccess.load(fromFilename: filename)
    }
    
    func saveState(_ user: LocalUser) -> AnyPublisher<Void, SavingError> {
        return fileAccess.save(filename: filename, object: user)
    }
    
    @discardableResult
    func deleteState() -> Result<Void, DeletionError> {
        return fileAccess.deleteFile(at: filename)
    }
    
}
