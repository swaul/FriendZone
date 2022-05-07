//
//  SignInViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 30.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import UIKit
import Toolbox
import Combine

class SetPasswordViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: RegisterViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    @IBOutlet var newPasswordTextfield: UITextField!
    @IBOutlet var confirmPasswordTextfield: UITextField!
    @IBOutlet var newPasswordTitleLabel: UILabel!
    @IBOutlet var confirmPasswordTitleLabel: UILabel!
    @IBOutlet var doneBUtton: FriendZoneButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var newPasswordErrorLabel: UILabel!
    @IBOutlet var confirmPasswordErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    var onSubmit: ((RegisterViewModel) -> Void)!
    
    var viewModel: RegisterViewModel!
    
    var cancellabels = Set<AnyCancellable>()
    
    func setupBindings() {
        Keyboard.shared.$info.sink { [weak self] info in
            self?.updateSafeAreaInsets(keyboardInfo: info, animated: true)
        }.store(in: &cancellabels)
        
        viewModel.$passwordStepValid.sink { [weak self] valid in
            self?.doneBUtton.isEnabled = valid
            guard let self = self else { return }
            if valid {
                self.showHideErrorMessage(hide: true, error: self.confirmPasswordErrorLabel)
                self.showHideErrorMessage(hide: true, error: self.newPasswordErrorLabel)
            }
        }.store(in: &cancellabels)
        
        viewModel.$userCreated.sink { [weak self] created in
            guard let self = self, let created = created else { return }
            if created {
                self.onSubmit(self.viewModel)
                self.doneBUtton.isLoading = false
            }
        }.store(in: &cancellabels)
        
        viewModel.newPassword.$validation.sink { [weak self] newValid in
            guard let self = self else { return }
            if let error = newValid.errorMessage {
                self.showHideErrorMessage(hide: false, error: self.newPasswordErrorLabel)
                self.newPasswordErrorLabel.text = error
            } else {
                self.showHideErrorMessage(hide: true, error: self.newPasswordErrorLabel)
            }
        }.store(in: &cancellabels)
        
        viewModel.$confirmPasswordValid.sink { [weak self] confirmValid in
            guard let self = self else { return }
            if confirmValid {
                self.showHideErrorMessage(hide: false, error: self.confirmPasswordErrorLabel)
                self.confirmPasswordErrorLabel.text = "Passwörter stimmen nicht überein"
            } else {
                self.showHideErrorMessage(hide: true, error: self.confirmPasswordErrorLabel)
            }
        }.store(in: &cancellabels)
    }

    func setupView() {
        view.layer.cornerRadius = 20
        
        titleLabel.text = "Passwort"

        confirmPasswordErrorLabel.setStyle(TextStyle.errorText)
        newPasswordErrorLabel.setStyle(TextStyle.errorText)
        
        confirmPasswordErrorLabel.isHidden = true
        newPasswordErrorLabel.isHidden = true
        
        newPasswordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        
        newPasswordTitleLabel.text = "Passwort erstellen"
        newPasswordTextfield.placeholder = "Neues Passwort"
        newPasswordTextfield.textContentType = .newPassword
        newPasswordTextfield.isSecureTextEntry = true
        newPasswordTextfield.enablePasswordToggle()
        
        confirmPasswordTitleLabel.text = "Password wiederholen"
        confirmPasswordTextfield.placeholder = "Passwort wiederholen"
        confirmPasswordTextfield.textContentType = .password
        confirmPasswordTextfield.isSecureTextEntry = true
        confirmPasswordTextfield.enablePasswordToggle()
        
        newPasswordTextfield.becomeFirstResponder()
        
        doneBUtton.setStyle(.primary)
        doneBUtton.setTitle("Fertig!", for: .normal)
    }
    
    @objc func hidePw() {
        newPasswordTextfield.isSecureTextEntry.toggle()
    }
    
    @objc func confirmHidePw() {
        confirmPasswordTextfield.isSecureTextEntry.toggle()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        doneBUtton.isLoading = true
        viewModel.registerUser()
    }
    
}

extension SetPasswordViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if newPasswordTextfield.isFirstResponder {
            viewModel.newPassword.value = text
        } else if confirmPasswordTextfield.isFirstResponder {
            viewModel.checkPassword(confirmedPassword: text)
        }
    }
    
}
