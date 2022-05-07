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
    @IBOutlet var emailErrorLabel: UILabel!
    @IBOutlet var passwordErrorLabel: UILabel!
    
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
        
        Publishers.CombineLatest(viewModel.email.$validation, viewModel.password.$validation).sink { [weak self] (emailValid, passwordValid) in
            self?.loginButton.isEnabled = emailValid.isValid && passwordValid.isValid
            if let error = emailValid.errorMessage {
                self?.viewModel.emailError = error
            } else {
                self?.viewModel.emailError = nil
            }
            if let error = passwordValid.errorMessage {
                self?.viewModel.passwordError = error
            } else {
                self?.viewModel.passwordError = nil
            }
        }.store(in: &cancellabels)
        
        viewModel.$passwordError.sink { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showHideErrorMessage(hide: false, error: self.passwordErrorLabel)
                self.passwordErrorLabel.text = error
            } else {
                self.showHideErrorMessage(hide: true, error: self.passwordErrorLabel)
            }
        }.store(in: &cancellabels)
        
        viewModel.$emailError.sink { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showHideErrorMessage(hide: false, error: self.emailErrorLabel)
                self.emailErrorLabel.text = error
            } else {
                self.showHideErrorMessage(hide: true, error: self.emailErrorLabel)
            }
        }.store(in: &cancellabels)
        
        viewModel.$shake.sink { [weak self] shake in
            if shake {
                self?.passwordTextfield.shakeIt()
                self?.emailTextField.shakeIt()
                self?.viewModel.shake = false
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
        emailErrorLabel.setStyle(TextStyle.errorText)
        emailErrorLabel.isHidden = true
        
        passwordTitleLabel.text = "Password"
        passwordTextfield.delegate = self
        passwordTextfield.placeholder = "Dein Passwort"
        passwordTextfield.textContentType = .password
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.rightViewMode = .always
        passwordTextfield.rightView?.isUserInteractionEnabled = true
        passwordTextfield.enablePasswordToggle()
        passwordErrorLabel.setStyle(TextStyle.errorText)
        passwordErrorLabel.isHidden = true
        
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if emailTextField.isFirstResponder {
            emailErrorLabel.isHidden = true
        } else if passwordTextfield.isFirstResponder {
            passwordErrorLabel.isHidden = true
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if emailTextField.isFirstResponder {
            viewModel.email.value = text
            textField.returnKeyType = .continue
        } else if passwordTextfield.isFirstResponder {
            viewModel.password.value = text
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

extension UITextField {
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if isSecureTextEntry {
            button.setImage(UIImage(systemSymbol: .eyeSlash), for: .normal)
        } else {
            button.setImage(UIImage(systemSymbol: .eye), for: .normal)
        }
    }
    
    func enablePasswordToggle() {
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        button.tintColor = Asset.primaryColor.color
        self.rightView = button
        self.rightViewMode = .always
    }
    @objc func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}

extension UIViewController {
    
    func showHideErrorMessage(hide: Bool, error: UILabel) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            error.isHidden = hide
        }, completion: nil)
    }
    
}
