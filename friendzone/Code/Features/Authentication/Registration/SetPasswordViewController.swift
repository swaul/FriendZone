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
    
    @IBOutlet var newPasswordTextfield: DesignableTextField!
    @IBOutlet var confirmPasswordTextfield: DesignableTextField!
    @IBOutlet var cancelButton: FriendZoneButton!
    @IBOutlet var doneBUtton: FriendZoneButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    var onBack: (() -> Void)!
    var onSubmit: (() -> Void)!
    
    var viewModel: RegisterViewModel!
    
    var cancellabels = Set<AnyCancellable>()
    
    func setupBindings() {
        Keyboard.shared.$info.sink { [weak self] info in
            self?.updateSafeAreaInsets(keyboardInfo: info, animated: true)
        }.store(in: &cancellabels)
        
        viewModel.$passwordStepValid.sink { [weak self] valid in
            self?.doneBUtton.isEnabled = valid
        }.store(in: &cancellabels)
        
        viewModel.$profileCreated.sink { [weak self] created in
            if created {
                self?.onSubmit()
            }
        }.store(in: &cancellabels)
    }

    func setupView() {
        newPasswordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        
        newPasswordTextfield.configure(style: .primary)
        newPasswordTextfield.placeholder = "Neues Passwort"
        newPasswordTextfield.textContentType = .newPassword
        newPasswordTextfield.isSecureTextEntry = true
        
        confirmPasswordTextfield.configure(style: .primary)
        confirmPasswordTextfield.placeholder = "Passwort wiederholen"
        confirmPasswordTextfield.textContentType = .password
        confirmPasswordTextfield.isSecureTextEntry = true
        
        cancelButton.setStyle(.tertiary)
        cancelButton.setTitle("Zurück", for: .normal)
        doneBUtton.setStyle(.primary)
        doneBUtton.setTitle("Fertig!", for: .normal)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        onBack()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
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
