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
    
    var onContinue: ((RegisterViewModel) -> Void)!
    var onBack: (() -> Void)!
    
    var viewModel: RegisterViewModel!
    
    @IBOutlet var instagramTextField: DesignableTextField!
    @IBOutlet var tiktokTextField: DesignableTextField!
    @IBOutlet var snapchatTextField: DesignableTextField!
    @IBOutlet var backButton: FriendZoneButton!
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
                self.instagramTextField.error = false
                self.instagramTextField.placeholder = self.instaPlaceholder
            } else {
                self.instagramTextField.error = true
                self.instagramTextField.placeholder = "Da scheint was nicht zu stimmen"
            }
        }.store(in: &cancellabels)
        
        viewModel.$tiktokValid.sink { [weak self] isValid in
            guard let self = self, let isValid = isValid else { return }
            if isValid {
                self.tiktokTextField.error = false
                self.tiktokTextField.placeholder = self.tiktokPlaceholder
            } else {
                self.tiktokTextField.error = true
                self.tiktokTextField.placeholder = "Da scheint was nicht zu stimmen"
            }
        }.store(in: &cancellabels)
    }
    
    func setupView() {
        instagramTextField.delegate = self
        instagramTextField.configure(style: .primary)
        instagramTextField.placeholder = instaPlaceholder
        instagramTextField.textContentType = .username
        instagramTextField.image = Asset.instagram.image
        
        tiktokTextField.delegate = self
        tiktokTextField.configure(style: .primary)
        tiktokTextField.placeholder = tiktokPlaceholder
        tiktokTextField.textContentType = .username
        tiktokTextField.image = Asset.tiktok.image
        
        snapchatTextField.delegate = self
        snapchatTextField.configure(style: .primary)
        snapchatTextField.placeholder = "Dein Snapchat Username"
        snapchatTextField.textContentType = .username
        snapchatTextField.image = Asset.snapchat.image
        
        backButton.setTitle("Zurück", for: .normal)
        backButton.setStyle(.tertiary)
        
        continiueButton.setTitle("Weiter", for: .normal)
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
    let tiktokPlaceholder: String = "Dein tiktok Username"
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        onContinue(viewModel)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        onBack()
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
            
        } else if snapchatTextField.isFirstResponder {
            
        }
        
        return true
    }
    
}
