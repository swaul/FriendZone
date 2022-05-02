//
//  LogniViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 29.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SFSafeSymbols
import Toolbox

class LoginViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: LoginViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    var viewModel: LoginViewModel!
    
    var onLogin: (() -> Void)!
    var onRegister: ((String) -> Void)!
    
    @IBOutlet var emailTextField: DesignableTextField!
    @IBOutlet var passwordTextfield: DesignableTextField!
    @IBOutlet var headerView: UIView!
    @IBOutlet var registerButton: FriendZoneButton!
    @IBOutlet var loginButton: FriendZoneButton!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    var cancellabels = Set<AnyCancellable>()
    
    func setupBindings() {
        viewModel.$onLogin.sink { [weak self] onLogin in
            if onLogin {
                self?.viewModel.onLogin = false
                self?.onLogin()
            }
        }.store(in: &cancellabels)
        
        viewModel.$error.sink { [weak self] errorMessage in
            guard let errorMessage = errorMessage else {
                self?.passwordTextfield.error = false
                return
            }
            self?.passwordTextfield.error = true
            self?.errorLabel.text = errorMessage
            self?.errorLabel.isHidden = false
        }.store(in: &cancellabels)
        
        passwordTextfield.publisher(for: \.isSecureTextEntry).sink { [weak self] isSecure in
            if isSecure {
                self?.passwordTextfield.rightImage = UIImage(systemSymbol: .eyeSlash)
            } else {
                self?.passwordTextfield.rightImage = UIImage(systemSymbol: .eye)
            }
        }.store(in: &cancellabels)
    }
    
    func setupView() {
        emailTextField.delegate = self
        emailTextField.configure(style: .primary)
        emailTextField.placeholder = "E-Mail"
        emailTextField.textContentType = .emailAddress
        emailTextField.keyboardType = .emailAddress
        emailTextField.image = UIImage(systemSymbol: .envelope).withTintColor(Asset.loginBlue.color)
        
        passwordTextfield.delegate = self
        passwordTextfield.configure(style: .primary)
        passwordTextfield.placeholder = "Passwort"
        passwordTextfield.textContentType = .password
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.image = UIImage(systemSymbol: .lock)
        
        passwordTextfield.rightImage = UIImage(systemSymbol: .eyeSlash)
        
        passwordTextfield.rightButtonTapped = { [weak self] in
            self?.passwordTextfield.isSecureTextEntry.toggle()
        }
        
        loginButton.setStyle(.primary)
        loginButton.setTitle("Login", for: .normal)
        registerButton.setStyle(.tertiary)
        registerButton.setTitle("Stattdessen registrieren", for: .normal)
        headerView.layer.cornerRadius = 20
        
        errorLabel.setStyle(TextStyle.errorText)
        errorLabel.isHidden = viewModel.error == nil
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    @objc func didTapOutside() {
        emailTextField.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        viewModel.login()
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        onRegister(emailTextField.text ?? "")
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if emailTextField.isFirstResponder {
            viewModel.email = text
            textField.returnKeyType = .continue
        } else if passwordTextfield.isFirstResponder {
            viewModel.password = text
            textField.returnKeyType = .send
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isFirstResponder {
            passwordTextfield.becomeFirstResponder()
        } else if passwordTextfield.isFirstResponder {
            viewModel.login()
        }
        return true
    }
    
}
