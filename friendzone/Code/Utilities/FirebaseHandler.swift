//
//  FirebaseHandler.swift
//  friendzone
//
//  Created by Paul Kühnel on 01.05.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import friendzoneKit

public class FirebaseHandler {
    
    public static let shared = FirebaseHandler()
    private var db = Firestore.firestore()
    
    func uploadUserData(userId: String, data: [String: Any], completion: ((Result<Void, FirebaseError>) -> Void)?) {
        db.collection("users").document(userId).setData(data) { error in
            if let error = error {
                completion?(.failure(FirebaseError.unknownError(error: error)))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    public func getData<T: FirebaseDecodable>(resource: LoadableResource<T>, _ completion: @escaping ((Result<[T], FirebaseError>) -> Void)) {
        var lastDocumentRef: DocumentReference?
        var lastCollectionRef: CollectionReference?
        
        for accessor in resource.path {
            switch accessor {
            case let .collection(collectionName):
                if let lastDocumentRef = lastDocumentRef {
                    lastCollectionRef = lastDocumentRef.collection(collectionName)
                } else {
                    lastCollectionRef = db.collection(collectionName)
                }
            case let .document(documentName):
                lastDocumentRef = lastCollectionRef?.document(documentName)
                
            }
        }
        
        let query: Query?
        if let constraint = resource.firebaseConstraint {
            switch constraint {
            case let .containsMultipleValue(fieldName, constraint):
                query = lastCollectionRef?.whereField(fieldName, in: constraint)
            case let .containsSingleValue(fieldName, constraint):
                query = lastCollectionRef?.whereField(fieldName, arrayContains: constraint)
            }
        } else {
            query = lastCollectionRef
        }
        
        query?.getDocuments { (querySnapshot, err) in
            
            if let err = err {
                completion(.failure(.unknownError(error: err)))
                print(err)
            } else {
                
                let notes = querySnapshot!.documents.compactMap { (document) -> T? in
                    let data = document.data()
                    
                    return T(data: data)
                }
                completion(.success((notes)))
            }
        }
    }
    
    public func updateLocation(postalCode: String, country: String, userId: String, _ completion: @escaping ((Result<Void, FirebaseError>) -> Void)) {
        let defaults = UserDefaults.standard
        if let recent = defaults.string(forKey: "recentLocation"), recent == postalCode {
            print("No need")
        } else {
            db.collection("locations").document(country).collection(postalCode).document(postalCode).updateData(["users": FieldValue.arrayUnion([userId])], completion: { error in
                if let error = error {
                    if error.localizedDescription.lowercased().contains(("No document to update").lowercased()) {
                        self.setLocation(postalCode: postalCode, country: country, userId: userId) { result in
                            switch result {
                            case .failure(let error):
                                completion(.failure(FirebaseError.unknownError(error: error)))
                            case .success(()):
                                completion(.success(()))
                            }
                        }
                    }
                    completion(.failure(.unknownError(error: error)))
                } else {
                    completion(.success(()))
                    let defaults = UserDefaults.standard
                    defaults.setValue(postalCode, forKey: "recentLocation")
                }
            })
        }
    }
    
    public func setLocation(postalCode: String, country: String, userId: String, _ completion: @escaping ((Result<Void, FirebaseError>) -> Void)) {
        db.collection("locations").document(country).collection(postalCode).document(postalCode).setData(["users": [userId]], completion: { error in
            if let error = error {
                completion(.failure(.unknownError(error: error)))
            } else {
                completion(.success(()))
                let defaults = UserDefaults.standard
                defaults.setValue(postalCode, forKey: "recentLocation")
            }
        })
    }
    
}
