//
//  ProfileViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 07.05.22.
//

import Foundation
import UIKit
import Combine
import Toolbox
import FirebaseAuth
import friendzoneKit
import SFSafeSymbols

class ProfileViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: ProfileViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    var viewModel: ProfileViewModel!
    
    var onImageTapped: ((UIImage) -> Void)!
    var onSignOut: (() -> Void)!
    var profileComplete: ((Bool) -> Void)!
    var didDismiss: (() -> Void)!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var profileTitleLabel: UILabel!
    @IBOutlet var editProfileButton: UIButton!
    @IBOutlet var profileVIew: UIView!
    @IBOutlet var profilePictureImageView: UIImageView!
    @IBOutlet var profileNameLabel: UITextField!
    @IBOutlet var profileBioTextView: UITextView!
    @IBOutlet var profileImagesStackView: UIStackView!
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var leftDeleteButton: UIButton!
    @IBOutlet var leftImageViewView: UIView!
    @IBOutlet var middleImageView: UIImageView!
    @IBOutlet var middleDeleteButton: UIButton!
    @IBOutlet var middleImageViewView: UIView!
    @IBOutlet var rightImageView: UIImageView!
    @IBOutlet var rightdelegetButton: UIButton!
    @IBOutlet var rightImageViewView: UIView!
    @IBOutlet var addImageView: UIView!
    @IBOutlet var addImageButton: UIButton!
    
    @IBOutlet var socialsTitleLabel: UILabel!
    @IBOutlet var socialsNotCompleteLabel: FriendZoneButton!
    @IBOutlet var socialsView: UIView!
    @IBOutlet var socialsStackViewsStackView: UIStackView!
    @IBOutlet var instaStackView: UIStackView!
    @IBOutlet var instaImage: UIImageView!
    @IBOutlet var inistaTextField: UITextField!
    @IBOutlet var tiktokStackView: UIStackView!
    @IBOutlet var tiktokImageView: UIImageView!
    @IBOutlet var tiktokTextField: UITextField!
    @IBOutlet var snapchatStackView: UIStackView!
    @IBOutlet var snapchatImageView: UIImageView!
    @IBOutlet var snapchatTextField: UITextField!
    
    @IBOutlet var inviteFriendsView: UIView!
    @IBOutlet var inviteFriendsButton: UIButton!
    @IBOutlet var inviteFriendsHeight: NSLayoutConstraint!
    
    @IBOutlet var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupHeader()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.bounds.height / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.getUser()
        socialsNotCompleteLabel.isHidden = viewModel.profileComplete
        didDismiss()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        profileComplete(true)
    }
    
    var cancellables = Set<AnyCancellable>()
    
    func setupBindings() {
        Keyboard.shared.$info.sink { [weak self] info in
            self?.adjustContentInsets(info: info)
        }.store(in: &cancellables)
        
        viewModel.$user.sink { [weak self] user in
            guard let user = user else { return }
            self?.populateInfo(user: user)
        }.store(in: &cancellables)
        
        viewModel.$profilePicture.sink { [weak self] image in
            self?.profilePictureImageView.image = image
        }.store(in: &cancellables)
        
        viewModel.$infosHaveChanged.sink { [weak self] changed in
            guard let self = self else { return }
            if !self.isEditing {
                self.inviteFriendsButton.isEnabled = true
            } else {
                self.inviteFriendsButton.isEnabled = changed
            }
        }.store(in: &cancellables)
        
        viewModel.$profileComplete.sink { [weak self] complete in
            self?.profileComplete(complete)
        }.store(in: &cancellables)
    }
    
    func setupViews() {
        scrollView.delegate = self
        showPictures()
        
        profileBioTextView.layer.cornerRadius = 8
        profileNameLabel.layer.cornerRadius = 8
        profileVIew.layer.cornerRadius = 8
        socialsView.layer.cornerRadius = 8
        leftImageView.layer.cornerRadius = 8
        middleImageView.layer.cornerRadius = 8
        rightImageView.layer.cornerRadius = 8
        inviteFriendsView.layer.cornerRadius = 8
        
        profilePictureImageView.layer.borderWidth = 2
        profilePictureImageView.layer.borderColor = Asset.accentColor.color.cgColor
        
        profileBioTextView.layer.borderWidth = 1
        profileBioTextView.layer.borderColor = UIColor.systemGray5.cgColor
        
        profileNameLabel.layer.borderWidth = 1
        profileNameLabel.layer.borderColor = UIColor.systemGray5.cgColor
        
        profileBioTextView.sizeToFit()
        
        profileTitleLabel.setStyle(TextStyle.grayBold)
        socialsTitleLabel.setStyle(TextStyle.grayBold)
        profileTitleLabel.text = "Dein Profil"
        socialsTitleLabel.text = "Soziales"
        socialsNotCompleteLabel.setTitle("Füge mehr Socials hinzu!", for: .normal)
        socialsNotCompleteLabel.setImage(UIImage(systemSymbol: .exclamationmarkCircleFill), for: .normal)
        socialsNotCompleteLabel.setStyle(.tertiary)
        socialsNotCompleteLabel.isHidden = viewModel.profileComplete
        
        tiktokImageView.image = Asset.tiktok.image
        
        profileNameLabel.delegate = self
        profileBioTextView.delegate = self
        inistaTextField.delegate = self
        tiktokTextField.delegate = self
        snapchatTextField.delegate = self
        
        profileNameLabel.isUserInteractionEnabled = false
        profileBioTextView.isUserInteractionEnabled = false
        
        leftDeleteButton.isHidden = true
        middleDeleteButton.isHidden = true
        rightdelegetButton.isHidden = true
        
        inistaTextField.isHidden = true
        tiktokTextField.isHidden = true
        snapchatTextField.isHidden = true
        socialsStackViewsStackView.axis = .horizontal
        
        signOutButton.setTitle("Abmelden", for: .normal)
        signOutButton.setTitleColor(.systemRed, for: .normal)
        
        let profileGesture = UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped))
        profilePictureImageView.addGestureRecognizer(profileGesture)
        profilePictureImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    func populateInfo(user: UserViewModel) {
        profileNameLabel.text = user.name
        profileBioTextView.text = user.bio
        
        inistaTextField.text = user.insta
        tiktokTextField.text = user.tiktok
        snapchatTextField.text = user.snap
        
        if profilePictureImageView.image == nil {
            viewModel.getImage(id: user.id)
        }
    }
    
    func showPictures() {
        let user = UserController.shared.loggedInUser

            switch user?.images.count {
            case 1:
                self.showHideImage(view: self.leftImageViewView, hide: false)
                self.showHideImage(view: self.middleImageViewView, hide: true)
                self.showHideImage(view: self.rightImageViewView, hide: true)
                self.showHideImage(view: self.addImageView, hide: false)
            case 2:
                self.showHideImage(view: self.leftImageViewView, hide: false)
                self.showHideImage(view: self.middleImageViewView, hide: false)
                self.showHideImage(view: self.rightImageViewView, hide: true)
                self.showHideImage(view: self.addImageView, hide: false)
            case 3:
                self.showHideImage(view: self.leftImageViewView, hide: false)
                self.showHideImage(view: self.middleImageViewView, hide: false)
                self.showHideImage(view: self.rightImageViewView, hide: false)
                self.showHideImage(view: self.addImageView, hide: true)
//                self.showHideImage(view: self.addImageView, hide: !self.isEditing)
            default:
                self.showHideImage(view: self.leftImageViewView, hide: true)
                self.showHideImage(view: self.middleImageViewView, hide: true)
                self.showHideImage(view: self.rightImageViewView, hide: true)
                self.showHideImage(view: self.addImageView, hide: true)
//                self.showHideImage(view: self.addImageView, hide: !self.isEditing)
            }
    }
    
    func showHideImage(view: UIView?, hide: Bool) {
        guard let view = view else { return }
        if hide {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                view.alpha = 0.0
                view.isHidden = true
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                view.isHidden = false
                view.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func setupHeader() {
        title = "Profil"
    }
    
    @objc func didTapOutside() {
        inistaTextField.resignFirstResponder()
        snapchatTextField.resignFirstResponder()
        tiktokTextField.resignFirstResponder()
        profileBioTextView.resignFirstResponder()
        profileNameLabel.resignFirstResponder()
    }
    
    func adjustContentInsets(info: Keyboard.Info) {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: info.keyboardHeight, right: 0)
    }
    
    @IBAction func toggleEditingTapped(_ sender: Any) {
        if !isEditing {
            setEditing(!isEditing, animated: true)
        } else if viewModel.infosHaveChanged {
            showUnsavedChangesDialog()
        } else {
            setEditing(!isEditing, animated: true)
        }
    }
    
    func showUnsavedChangesDialog() {
        let dialog = UIAlertController(title: "Du hast ungespeicherte Änderungen", message: "Willst du deine Änderungen speichern?", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Speichern", style: .default) { [weak self] _ in
            self?.viewModel.updateInfo(completion: { [weak self] success in
                if success {
                    self?.setEditing(false, animated: true)
                } else {
                    self?.view.shakeIt()
                }
            })
        }
        
        let dismissAction = UIAlertAction(title: "Verwerfen", style: .destructive) { [weak self] _ in
            
            self?.setEditing(false, animated: true)
        }
        
        dialog.addAction(saveAction)
        dialog.addAction(dismissAction)
        
        present(dialog, animated: true)
    }
    
    @IBAction func inviteFriendsButtonTapped(_ sender: Any) {
        if isEditing {
            viewModel.updateInfo { [weak self] success in
                if success {
                    self?.setEditing(false, animated: true)
                } else {
                    self?.view.shakeIt()
                }
            }
        } else {
            "Invite friends"
        }
    }
    
    @objc func profilePictureTapped() {
        if isEditing {
            CameraPermissionHandler.checkCameraPermission(viewController: self) { [weak self] in
                DispatchQueue.main.async {
                    self?.showImagePicker()
                }
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
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        showPictures()
        profileNameLabel.isUserInteractionEnabled = editing
        profileBioTextView.isUserInteractionEnabled = editing
        if !editing {
            self.didTapOutside()
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            if editing {
                self.inviteFriendsButton.isEnabled = false
                self.editProfileButton.setImage(.xmarkCircle, for: .normal)
                self.socialsStackViewsStackView.axis = .vertical
                self.inistaTextField.isHidden = false
                self.tiktokTextField.isHidden = false
                self.snapchatTextField.isHidden = false
                self.leftDeleteButton.isHidden = false
                self.middleDeleteButton.isHidden = false
                self.rightdelegetButton.isHidden = false
                self.inistaTextField.alpha = 1.0
                self.tiktokTextField.alpha = 1.0
                self.snapchatTextField.alpha = 1.0
                self.profileNameLabel.backgroundColor = .systemBackground
                self.profileBioTextView.backgroundColor = .systemBackground
                self.inviteFriendsButton.setTitle("Änderungen Speichern", for: .normal)
                self.inviteFriendsButton.setImage(.squareAndArrowDown, for: .normal)
            } else {
                self.editProfileButton.setImage(.rectangleAndPencilAndEllipsis, for: .normal)
                self.profileNameLabel.backgroundColor = .clear
                self.profileBioTextView.backgroundColor = .clear
                self.socialsStackViewsStackView.axis = .horizontal
                self.inistaTextField.alpha = 0.0
                self.tiktokTextField.alpha = 0.0
                self.snapchatTextField.alpha = 0.0
                self.inistaTextField.isHidden = true
                self.tiktokTextField.isHidden = true
                self.snapchatTextField.isHidden = true
                self.leftDeleteButton.isHidden = true
                self.middleDeleteButton.isHidden = true
                self.rightdelegetButton.isHidden = true
                self.inviteFriendsButton.setTitle("Lade deine Freunde ein", for: .normal)
                self.inviteFriendsButton.setImage(.squareAndArrowUp, for: .normal)
            }
        } completion: { completed in
            if completed {
                print(editing)
            }
            if !editing {
                
            }
        }
    }
    
    @IBAction func addSocialsButtonTapped(_ sender: Any) {
        setEditing(true, animated: true)
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        showSignOutDialog()
    }
    
    func showSignOutDialog() {
        let dialog = UIAlertController(title: "Abmelden", message: "Willst du dich wirklich abmelden?", preferredStyle: .alert)
        
        let logoutAction = UIAlertAction(title: "Abmelden", style: .destructive) { [weak self] _ in
            self?.viewModel.resetData()
            self?.onSignOut()
        }
        
        let cancel = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
        
        dialog.addAction(logoutAction)
        dialog.addAction(cancel)
        
        present(dialog, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as! UIImage
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.onImageTapped(image)
        }
    }
    
}

extension ProfileViewController: UIScrollViewDelegate {
    
}

extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text, let user = viewModel.user else { return }
        if profileNameLabel.isFirstResponder {
            viewModel.changedName = UserInfo(value: user.name, newValue: text, type: .name)
        } else if tiktokTextField.isFirstResponder {
            viewModel.changedTikTok = UserInfo(value: user.tiktok, newValue: text, type: .tiktok)
        } else if inistaTextField.isFirstResponder {
            viewModel.changedInsta = UserInfo(value: user.insta, newValue: text, type: .insta)
        } else if snapchatTextField.isFirstResponder {
            viewModel.changedSnap = UserInfo(value: user.snap, newValue: text, type: .snap)
        }
    }
    
}

extension ProfileViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        viewModel.changedBio = UserInfo(value: viewModel.user!.bio, newValue: text, type: .bio)
        return true
    }
    
}
