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

class ProfileViewModel: ImagePicker {
    
    @Published var profilePicture: UIImage? {
        didSet {
            uploadImage()
        }
    }
    
    let storageRef = Storage.storage().reference()
    @Published var percentComplete: Float = 0.0
    @Published var profileCreated: Bool = false
    
    init() {
        print("new profile screen")
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
    
}

protocol ImagePicker {
    var profilePicture: UIImage? { get set }
}
