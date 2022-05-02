//
//  RegisterViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 30.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import UIKit
import Combine
import Toolbox

class RegisterViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: RegisterViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    @IBOutlet var nameTextField: DesignableTextField!
    @IBOutlet var emailTextField: DesignableTextField!
    @IBOutlet var phoneNumberTextField: DesignableTextField!
    @IBOutlet var continueButton: FriendZoneButton!
    @IBOutlet var cancelButton: FriendZoneButton!
    
    var onContinue: ((RegisterViewModel) -> Void)!
    var onBack: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    var viewModel: RegisterViewModel!
    
    var cancellabels = Set<AnyCancellable>()
    
    func setupBindings() {
        Keyboard.shared.$info.sink { [weak self] info in
            self?.updateSafeAreaInsets(keyboardInfo: info, animated: true)
        }.store(in: &cancellabels)
        
        viewModel.$emailStepValid.sink { [weak self] valid in
            self?.continueButton.isEnabled = valid
        }.store(in: &cancellabels)
    }
    
    func setupView() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneNumberTextField.delegate = self
        
        nameTextField.configure(style: .primary)
        nameTextField.placeholder = "Name"
        nameTextField.textContentType = .name
        emailTextField.configure(style: .primary)
        emailTextField.placeholder = "E-Mail"
        emailTextField.textContentType = .emailAddress
        emailTextField.keyboardType = .emailAddress
        phoneNumberTextField.configure(style: .primary)
        phoneNumberTextField.placeholder = "Telefonnummer"
        phoneNumberTextField.textContentType = .telephoneNumber
        phoneNumberTextField.keyboardType = .phonePad
        
        emailTextField.text = viewModel.email.value
        nameTextField.becomeFirstResponder()
        
        cancelButton.setStyle(.tertiary)
        cancelButton.setTitle("Zurück", for: .normal)
        continueButton.setStyle(.primary)
        continueButton.setTitle("Weiter", for: .normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    @objc func didTapOutside() {
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        phoneNumberTextField.resignFirstResponder()
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        onContinue(viewModel)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        onBack()
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if nameTextField.isFirstResponder {
            viewModel.name.value = text
        } else if emailTextField.isFirstResponder {
            viewModel.email.value = text
        } else if phoneNumberTextField.isFirstResponder {
            textField.returnKeyType = .done
            viewModel.phoneNumber.value = text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTextField.isFirstResponder {
            emailTextField.becomeFirstResponder()
        } else if emailTextField.isFirstResponder {
            phoneNumberTextField.becomeFirstResponder()
        } else if phoneNumberTextField.isFirstResponder {
            onContinue(viewModel)
        }
        return true
    }
    
}
