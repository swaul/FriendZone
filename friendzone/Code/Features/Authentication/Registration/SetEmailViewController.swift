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
    @IBOutlet var continueButton: FriendZoneButton!
    
    var onContinue: ((RegisterViewModel) -> Void)!
    
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
    
    @objc func didTapOutside() {
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        onContinue(viewModel)
    }
    
}

extension SetEmailViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        viewModel.email.value = text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        return true
    }
    
}
