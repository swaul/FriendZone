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
import SimpleButton

class RegisterViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: RegisterViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var nameTitleLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var loginInsteadHintLabel: UILabel!
    @IBOutlet var loginInsteadButton: SimpleButton!
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
        
        viewModel.$usernameValid.sink { [weak self] valid in
            self?.continueButton.isEnabled = valid
        }.store(in: &cancellabels)
    }
    
    func setupView() {
        nameTextField.delegate = self

        nameTitleLabel.text = "Benutzernamen erstellen"
        nameTextField.placeholder = "Benutzername"
        nameTextField.textContentType = .name
        nameTextField.becomeFirstResponder()
        
        loginInsteadHintLabel.setStyle(TextStyle.normalTiny)
        loginInsteadHintLabel.text = "Ich habe bereits einen Account"
        
        loginInsteadButton.setTitle("Login", for: .normal)
        continueButton.setStyle(.primary)
        continueButton.setTitle("Weiter", for: .normal)
        
        view.layer.cornerRadius = 20
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    @objc func didTapOutside() {
        nameTextField.resignFirstResponder()
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        onContinue(viewModel)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        viewModel.name.value = text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
}
