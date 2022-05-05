//
//  SetSocialMediaViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 01.05.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import UIKit
import Combine
import Toolbox

class SetSocialMediaViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: RegisterViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    var onContinue: (() -> Void)!
    var onBack: (() -> Void)!
    
    var viewModel: RegisterViewModel!
    
    @IBOutlet var instagramTitleLabel: UILabel!
    @IBOutlet var instagramTextField: UITextField!
    @IBOutlet var tiktokTitleLabel: UILabel!
    @IBOutlet var tiktokTextField: UITextField!
    @IBOutlet var snapchatTitleLabel: UILabel!
    @IBOutlet var snapchatTextField: UITextField!
    @IBOutlet var continiueButton: FriendZoneButton!

    var cancellabels = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    func setupBindings() {
        Keyboard.shared.$info.sink { [weak self] info in
            self?.updateSafeAreaInsets(keyboardInfo: info, animated: true)
        }.store(in: &cancellabels)
        
        viewModel.$instagramValid.sink { [weak self] isValid in
            guard let self = self, let isValid = isValid else { return }
            if isValid {
                self.instagramTextField.textColor = Asset.textColor.color
                self.instagramTextField.placeholder = self.instaPlaceholder
            } else {
                self.instagramTextField.textColor = .systemRed
                self.instagramTextField.placeholder = "Da scheint was nicht zu stimmen"
            }
        }.store(in: &cancellabels)
        
        viewModel.$tiktokValid.sink { [weak self] isValid in
            guard let self = self, let isValid = isValid else { return }
            if isValid {
                self.tiktokTextField.textColor = Asset.textColor.color
                self.tiktokTextField.placeholder = self.tiktokPlaceholder
            } else {
                self.tiktokTextField.textColor = .systemRed
                self.tiktokTextField.placeholder = "Da scheint was nicht zu stimmen"
            }
        }.store(in: &cancellabels)
        
        viewModel.$profileCreated.sink { [weak self] created in
            if created {
                self?.onContinue()
            }
        }.store(in: &cancellabels)
    }
    
    func setupView() {
        view.layer.cornerRadius = 20

        instagramTitleLabel.text = "Instagram"
        instagramTextField.delegate = self
        instagramTextField.placeholder = instaPlaceholder
        instagramTextField.textContentType = .username
        instagramTextField.leftView = UIImageView(image: Asset.instagram.image)
        
        tiktokTitleLabel.text = "TikTok"
        tiktokTextField.delegate = self
        tiktokTextField.placeholder = tiktokPlaceholder
        tiktokTextField.textContentType = .username
        tiktokTextField.leftView = UIImageView(image: Asset.tiktok.image)
        
        snapchatTitleLabel.text = "Snapchat"
        snapchatTextField.delegate = self
        snapchatTextField.placeholder = "Dein Snapchat Username"
        snapchatTextField.textContentType = .username
        snapchatTextField.leftView = UIImageView(image: Asset.snapchat.image)
        
        continiueButton.setTitle("Fertig!", for: .normal)
        continiueButton.setStyle(.primary)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    @objc func didTapOutside() {
        instagramTextField.resignFirstResponder()
        tiktokTextField.resignFirstResponder()
        snapchatTextField.resignFirstResponder()
    }
    
    let instaPlaceholder: String = "Dein Instagram Username"
    let tiktokPlaceholder: String = "Dein TikTok Username"
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        viewModel.uploadImage()
    }
}

extension SetSocialMediaViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if instagramTextField.isFirstResponder {
            self.viewModel.instagram = text
        } else if tiktokTextField.isFirstResponder {
            self.viewModel.tiktok = text
        } else if snapchatTextField.isFirstResponder {
            self.viewModel.snapchat = text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if instagramTextField.isFirstResponder {
            tiktokTextField.becomeFirstResponder()
        } else if tiktokTextField.isFirstResponder {
            snapchatTextField.becomeFirstResponder()
        } else if snapchatTextField.isFirstResponder {
            snapchatTextField.resignFirstResponder()
        }
        
        return true
    }
    
}
