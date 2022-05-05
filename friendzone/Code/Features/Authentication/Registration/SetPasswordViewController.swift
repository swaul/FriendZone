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
        }.store(in: &cancellabels)
        
        viewModel.$userCreated.sink { [weak self] created in
            guard let self = self, let created = created else { return }
            if created {
                self.onSubmit(self.viewModel)
            }
        }.store(in: &cancellabels)
    }

    func setupView() {
        view.layer.cornerRadius = 20

        newPasswordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        
        let showPwButton = UIButton().with {
            $0.setImage(.eyeSlash, for: .normal)
            $0.addTarget(self, action: #selector(hidePw), for: .touchUpInside)
        }
        
        let confirmShowPwButton = UIButton().with {
            $0.setImage(.eyeSlash, for: .normal)
            $0.addTarget(self, action: #selector(confirmHidePw), for: .touchUpInside)
        }
        
        newPasswordTitleLabel.text = "Passwort erstellen"
        newPasswordTextfield.placeholder = "Neues Passwort"
        newPasswordTextfield.textContentType = .newPassword
        newPasswordTextfield.isSecureTextEntry = true
        newPasswordTextfield.rightView = showPwButton
        
        confirmPasswordTitleLabel.text = "Password wiederholen"
        confirmPasswordTextfield.placeholder = "Passwort wiederholen"
        confirmPasswordTextfield.textContentType = .password
        confirmPasswordTextfield.isSecureTextEntry = true
        newPasswordTextfield.rightView = confirmShowPwButton
        
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
