//
//  EmailVerificationViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 04.05.22.
//

import Foundation
import UIKit
import Combine
import Toolbox
import FirebaseAuth

class EmailVerificationViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: RegisterViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var continueButton: FriendZoneButton!
    @IBOutlet var verifyHintLabel: UILabel!
    
    var onContinue: ((RegisterViewModel) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkVerification { [weak self] verified in
            guard let self = self else { return }
            if verified {
                self.onContinue(self.viewModel)
            }
        }
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
    
    func hideMidChars(_ value: String) -> String {
       return String(value.enumerated().map { index, char in
          return [0, 1, value.count - 1, value.count - 0].contains(index) ? char : "*"
       })
    }
    
    func hideMailMid(_ value: String) -> String {
        guard value.contains("@") else { return "" }
        let components = value.components(separatedBy: "@")
        let result = hideMidChars(components.first!) + "@" + components.last!
        return result
    }
    
    func setupView() {
        titleLabel.text = "Verifizieren"
        
        verifyHintLabel.text = """
        Zur Sicherheit haben wir dir eine Email an
        \(hideMailMid(viewModel.email.value!))
        mit einem Link geschickt.
        Bitte bestätige damit deine Email und klicke anschließend auf weiter!
        """
        verifyHintLabel.setStyle(TextStyle.blueSmall)
        
        continueButton.setStyle(.primary)
        continueButton.setTitle("Weiter", for: .normal)
        
        view.layer.cornerRadius = 20
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        viewModel.checkVerification { [weak self] verified in
            guard let self = self else { return }
            if verified {
                self.onContinue(self.viewModel)
            }
        }
    }
    
}
