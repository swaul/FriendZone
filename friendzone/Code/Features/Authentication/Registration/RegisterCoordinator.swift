//
//  RegisterCoordinator.swift
//  friendzone
//
//  Created by Paul Kühnel on 04.05.22.
//

import Foundation

class RegisterCoordinator: CardCoordinator {
    
    var onSubmit: (() -> Void)!
    
    override init() {
        super.init()
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    override func start() {
        let viewModel = RegisterViewModel()
        let viewController = RegisterViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onContinue = { [weak self] viewModel in
            self?.showEmailSetup(viewModel: viewModel)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showEmailSetup(viewModel: RegisterViewModel) {
        let viewController = SetEmailViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onContinue = { [weak self] viewModel in
            self?.showPasswortSetup(viewModel: viewModel)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showEmailVerification(viewModel: RegisterViewModel) {
        let viewController = EmailVerificationViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onContinue = { [weak self] viewModel in
            self?.showProfileSetup(viewModel: viewModel)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showProfileSetup(viewModel: RegisterViewModel) {
        let viewController = SetProfilePictureViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onContinue = { [weak self] viewModel in
            self?.showSocialMediaSetup(viewModel: viewModel)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSocialMediaSetup(viewModel: RegisterViewModel) {
        let viewController = SetSocialMediaViewController.createWith(storyboard: .auth, viewModel: viewModel)

        viewController.onContinue = onSubmit
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showPasswortSetup(viewModel: RegisterViewModel) {
        let viewController = SetPasswordViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onSubmit = { [weak self] viewModel in
            self?.showEmailVerification(viewModel: viewModel)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
