//
//  FirebaseHelpers.swift
//  friendzoneKit
//
//  Created by Paul Kühnel on 01.05.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation

public class LoadableSharedResource<T: FirebaseDecodable> {
    public var id: String
    
    public init(id: String) {
        self.id = id
    }
}

public enum FirebaseError: Error {
    case unknownError(error: Error)
    case urlNotFound
    case authError
    case genericError
}

public protocol FirebaseDecodable {
    init?(data: [String: Any])
    
}

public class LoadableResource<T: FirebaseDecodable> {
    public let path: [FirebaseAccessor]
    public let firebaseConstraint: FirebaseConstraint?
    
    public init(path: [FirebaseAccessor], firebaseConstraint: FirebaseConstraint? = nil) {
        self.path = path
        self.firebaseConstraint = firebaseConstraint
    }
    
}

public class UpdateResource {
    public let path: [FirebaseAccessor]
    public let data: FirebaseUpdatesFor
    public let lastChangeDate: Double
    
    public init(path: [FirebaseAccessor], data: FirebaseUpdatesFor) {
        self.path = path
        self.data = data
        lastChangeDate = (Date().timeIntervalSince1970 * 1000.0).rounded()
    }
}

public enum FirebaseAccessor {
    case collection(collectionName: String)
    case document(documentName: String)
}

public struct Resource {
    
    public init(data: [String: Any], path: [FirebaseAccessor]) {
        self.data = data
        self.path = path
    }
    
    public let data: [String: Any]
    public let path: [FirebaseAccessor]
}

public enum FirebaseConstraint {
    case containsSingleValue(fieldName: String, constraint: String)
    case containsMultipleValue(fieldName: String, constraint: [String])
}

public enum FirebaseUpdatesFor {
    case changeInArray(fieldName: String, shouldContainUser: Bool, userID: String)
    case changeInNote(title: String, content: String, password: String)
    case changeInChecklist(title: String, content: [[String: Any]], password: String)
    case changeSharedState(fieldName: String, state: Bool)
    case changePassword(
            firstFieldName: String,
            passwordHash: String,
            secondFieldName: String,
            needsPassword: Bool,
            thirdFieldName: String,
            userID: String
    )
}
