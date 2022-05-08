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

class ProfileViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: ProfileViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    var viewModel: ProfileViewModel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var profileTitleLabel: UILabel!
    @IBOutlet var editProfileButton: UIButton!
    @IBOutlet var profileVIew: UIView!
    @IBOutlet var profilePictureImageView: UIImageView!
    @IBOutlet var profileNameLabel: UITextField!
    @IBOutlet var profileBioTextView: UITextView!
    @IBOutlet var profileImagesStackView: UIStackView!
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var middleImageView: UIImageView!
    @IBOutlet var rightImageView: UIImageView!
    
    @IBOutlet var socialsTitleLabel: UILabel!
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
    
    var cancellables = Set<AnyCancellable>()
    
    func setupBindings() {
        Keyboard.shared.$info.sink { [weak self] info in
            self?.adjustContentInsets(info: info)
        }.store(in: &cancellables)
    }
    
    func setupViews() {
        scrollView.delegate = self
        
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
        
        profileNameLabel.isUserInteractionEnabled = false
        profileBioTextView.isUserInteractionEnabled = false
        
        inistaTextField.isHidden = true
        tiktokTextField.isHidden = true
        snapchatTextField.isHidden = true
        socialsStackViewsStackView.axis = .horizontal
                
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    func setupHeader() {
        
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = UIFont.boldSystemFont(ofSize: 42)
        headerLabel.textColor = Asset.primaryColor.color
        headerLabel.text = "Profil"
        
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerLabel)
        
        headerLabel.withConstraints { view in
            view.alignEdges()
        }
        
        navigationItem.titleView = headerView
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
        setEditing(!isEditing, animated: true)
    }
    
    @IBAction func inviteFriendsButtonTapped(_ sender: Any) {
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        profileNameLabel.isUserInteractionEnabled = editing
        profileBioTextView.isUserInteractionEnabled = editing
        if !editing {
            self.didTapOutside()
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            if editing {
                self.editProfileButton.setImage(.xmarkCircle, for: .normal)
                self.socialsStackViewsStackView.axis = .vertical
                self.inistaTextField.isHidden = false
                self.tiktokTextField.isHidden = false
                self.snapchatTextField.isHidden = false
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
}

extension ProfileViewController: UIScrollViewDelegate {
    
}
