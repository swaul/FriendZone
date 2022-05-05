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
    
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
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
//            guard let errorMessage = errorMessage else {
//                self?.passwordTextfield.error = false
//                return
//            }
//            self?.passwordTextfield.error = true
            //                    self?.errorLabel.text = errorMessage
            //                    self?.errorLabel.isHidden = false
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
        
        emailTextField.delegate = self
        emailTextField.placeholder = "E-Mail"
        emailTextField.textContentType = .emailAddress
        emailTextField.keyboardType = .emailAddress
        
        passwordTextfield.delegate = self
        passwordTextfield.placeholder = "Passwort"
        passwordTextfield.textContentType = .password
        passwordTextfield.isSecureTextEntry = true
        
        //                errorLabel.setStyle(TextStyle.errorText)
        //                errorLabel.isHidden = viewModel.error == nil
        //
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    @objc func didTapOutside() {
        emailTextField.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
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
