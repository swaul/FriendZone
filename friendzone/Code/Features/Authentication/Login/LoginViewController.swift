//
//  LoginViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 05.05.22.
//

import Foundation
import UIKit
import Combine

class LoginViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: LoginViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    var onLogin: (() -> Void)!
    
    var viewModel: LoginViewModel!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var emailTitleLabel: UILabel!
    @IBOutlet var passwordTitleLabel: UILabel!
    @IBOutlet var forgotPasswordButton: FriendZoneButton!
    @IBOutlet var registerHintLabel: UILabel!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var loginButton: FriendZoneButton!
    
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

        passwordTextfield.publisher(for: \.isSecureTextEntry).sink { [weak self] isSecure in
            if isSecure {
                self?.passwordTextfield.rightView = UIImageView(image: UIImage(systemSymbol: .eyeSlash))
            } else {
                self?.passwordTextfield.rightView = UIImageView(image: UIImage(systemSymbol: .eye))
            }
        }.store(in: &cancellabels)
    }
    
    func setupView() {
        
        view.layer.cornerRadius = 20
        
        emailTitleLabel.text = "E-mail"
        emailTextField.delegate = self
        emailTextField.placeholder = "Deine E-Mail"
        emailTextField.textContentType = .emailAddress
        emailTextField.keyboardType = .emailAddress
        
        passwordTitleLabel.text = "Password"
        passwordTextfield.delegate = self
        passwordTextfield.placeholder = "Dein Passwort"
        passwordTextfield.textContentType = .password
        passwordTextfield.isSecureTextEntry = true
        
        forgotPasswordButton.setStyle(.tertiary)
        forgotPasswordButton.setTitle("Password vergessen", for: .normal)
        
        registerHintLabel.text = "Ich habe noch keinen Account"
        registerButton.setTitle("Registrieren", for: .normal)
        
        loginButton.setStyle(.primary)
        loginButton.setTitle("Login", for: .normal)
    
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
