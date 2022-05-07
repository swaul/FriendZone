//
//  SetEmailViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 04.05.22.
//

import Foundation
import UIKit
import Combine
import Toolbox

class SetEmailViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: RegisterViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var emailTitleLabel: UILabel!
    @IBOutlet var emailErrorLabel: UILabel!
    @IBOutlet var continueButton: FriendZoneButton!
    
    var onContinue: ((RegisterViewModel) -> Void)!
    
    @Published var emailError: String?
    
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
        
        $emailError.sink { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.emailErrorLabel.text = error
                self.showHideErrorMessage(hide: false, error: self.emailErrorLabel)
            } else {
                self.showHideErrorMessage(hide: true, error: self.emailErrorLabel)
            }
        }.store(in: &cancellabels)
    }
    
    func setupView() {
        emailErrorLabel.setStyle(TextStyle.errorText)
        emailErrorLabel.isHidden = true
        
        titleLabel.text = "E-Mail Adresse"
        emailTextField.delegate = self

        emailTitleLabel.text = "E-Mail Adresse hinzufügen"
        
        emailTextField.placeholder = "Email"
        emailTextField.textContentType = .emailAddress
        emailTextField.keyboardType = .emailAddress
        emailTextField.becomeFirstResponder()

        continueButton.setStyle(.primary)
        continueButton.setTitle("Weiter", for: .normal)
        
        view.layer.cornerRadius = 20
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    func checkEmail() {
        continueButton.isLoading = true
        if viewModel.emailStepValid {
            viewModel.isEmailInUse { [weak self] isInUse in
                guard let self = self else { return }
                if isInUse {
                    self.continueButton.isLoading = false
                    self.emailTextField.shakeIt()
                    self.emailError = "E-Mail wird bereits verwendet"
                } else {
                    self.continueButton.isLoading = false
                    self.onContinue(self.viewModel)
                }
            }
        }
    }
    
    @objc func didTapOutside() {
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        checkEmail()
    }
    
}

extension SetEmailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailError = nil
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        viewModel.email.value = text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkEmail()
        emailTextField.resignFirstResponder()
        return true
    }
    
}
