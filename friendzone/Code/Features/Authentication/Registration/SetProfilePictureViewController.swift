//
//  SetProfilePictureViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 01.05.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Combine
import Toolbox

class SetProfilePictureViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: RegisterViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    var onContinue: ((RegisterViewModel) -> Void)!
    var onBack: (() -> Void)!
    
    var viewModel: RegisterViewModel!
    
    @IBOutlet var profilePictureImageView: UIImageView!
    @IBOutlet var profilePictureHintLabel: UILabel!
    @IBOutlet var bioHintLabel: UILabel!
    @IBOutlet var bioTextView: UITextView!
    @IBOutlet var continueButton: FriendZoneButton!
    @IBOutlet var counter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    var cancellabels = Set<AnyCancellable>()
    
    func setupBindings() {
        Keyboard.shared.$info.sink { [weak self] info in
            self?.updateSafeAreaInsets(keyboardInfo: info, animated: true)
        }.store(in: &cancellabels)
    }
    
    func setupView() {
        view.layer.cornerRadius = 20

        profilePictureImageView.layer.cornerRadius = profilePictureImageView.bounds.height / 2
        profilePictureImageView.layer.borderWidth = 2
        profilePictureImageView.layer.borderColor = Asset.accentColor.color.cgColor
        
        bioHintLabel.setStyle(TextStyle.blueNormal)
        bioHintLabel.text = "Füge einen Steckbrief hinzu"
        
        profilePictureHintLabel.setStyle(TextStyle.blueNormal)
        profilePictureHintLabel.text = "Füge ein Profilbild hinzu"
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        profilePictureImageView.addGestureRecognizer(gesture)
        profilePictureImageView.isUserInteractionEnabled = true
        bioTextView.delegate = self
        
        counter.text = "0/140"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        continueButton.setStyle(.primary)
        continueButton.setTitle("Fast geschafft", for: .normal)
    }
    
    @objc func didTapOutside() {
        bioTextView.resignFirstResponder()
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        onContinue(viewModel)
    }
    
    @objc func didTapImage() {
        CameraPermissionHandler.checkCameraPermission(viewController: self) { [weak self] in
            DispatchQueue.main.async {
                self?.showImagePicker()
            }
        }
    }
    
    func showImagePicker() {
        let alertVC = UIAlertController(title: "Wähle eine Quelle", message: "Willst du ein neues Bild machen, oder eines aus der Galerie wählen?", preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "Neues Bild", style: .default) { [weak self] _ in
            self?.createImagePicker(source: .camera)
        }
        
        let galleryAction = UIAlertAction(title: "Aus Galerie", style: .default) { [weak self] _ in
            self?.createImagePicker(source: .photoLibrary)
        }
        
        let cancel = UIAlertAction(title: "Abbrechen", style: .cancel)
        
        alertVC.addAction(cameraAction)
        alertVC.addAction(galleryAction)
        alertVC.addAction(cancel)
        
        present(alertVC, animated: true)
    }
    
    private func createImagePicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
}

extension SetProfilePictureViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        counter.text = "\(text.count)/140"
        viewModel.bio = text
    }
    
}

extension SetProfilePictureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as! UIImage
        self.profilePictureImageView.image = image
        self.viewModel.profilePicture = image
        self.dismiss(animated: true)
    }
    
}

public class CameraPermissionHandler {
    
    static func checkCameraPermission(viewController: UIViewController, onAuthorized: @escaping (() -> Void)) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            onAuthorized()
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    onAuthorized()
                }
            }
        case .denied: // The user has previously denied access.
            self.cameraPermissionDeniedDialog(viewController: viewController)
        default:
            return
        }
    }
    
    static func cameraPermissionDeniedDialog(viewController: UIViewController) {
        let dialog = UIAlertController(title: "Camera permission error", message: "The app cannot access the camera of the device. Go to the device settings and allow access to the camera.", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { _ in
            viewController.dismiss(animated: true, completion: nil)
        }
        dialog.addAction(yesAction)
        dialog.addAction(cancelAction)
        
        viewController.present(dialog, animated: true, completion: nil)
    }
    
}
