//
//  RegisterCoordinator.swift
//  friendzone
//
//  Created by Paul Kühnel on 04.05.22.
//

import Foundation
import UIKit

class RegisterCoordinator: CardCoordinator {
    
    var onSubmit: (() -> Void)!
    var onLogin: (() -> Void)!
    
    override init() {
        super.init()
        
        cardViewController.onBack = { [weak self] in
            if self?.navigationController.viewControllers.count == 1 {
                self?.onDismiss()
            } else {
                self?.navigationController.popViewController(animated: true)
                self?.cardViewController.updateBackButton(title: self?.getTitle(for: self?.navigationController.viewControllers.count ?? -1) ?? "Zurück")
            }
        }
        
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    var viewModel: RegisterViewModel!
    
    override func start() {
        viewModel = RegisterViewModel()
        let viewController = RegisterViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onContinue = { [weak self] viewModel in
            self?.cardViewController.updateBackButton(title: "Benutzername")
            self?.showEmailSetup(viewModel: viewModel)
        }
        
        viewController.onLogin = { [weak self] in
            self?.onLogin()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showEmailSetup(viewModel: RegisterViewModel) {
        let viewController = SetEmailViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onContinue = { [weak self] viewModel in
            self?.cardViewController.updateBackButton(title: "E-Mail Adresse")
            self?.showPasswortSetup(viewModel: viewModel)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showEmailVerification(viewModel: RegisterViewModel) {
        let viewController = EmailVerificationViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onContinue = { [weak self] viewModel in
            self?.cardViewController.updateBackButton(title: "E-Mail Verifizieren")
            self?.showProfileSetup(viewModel: viewModel)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showProfileSetup(viewModel: RegisterViewModel) {
        let viewController = SetProfilePictureViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onContinue = { [weak self] viewModel in
            self?.cardViewController.updateBackButton(title: "Steckbrief")
            self?.showSocialMediaSetup(viewModel: viewModel)
        }
        
        viewController.onImageCrop = { [weak self] image, viewModel in
            self?.showImageCropper(viewModel: viewModel, image: image)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showImageCropper(viewModel: RegisterViewModel, image: UIImage) {
        let viewController = ImageCropperViewController.createWith(storyboard: .auth, viewModel: viewModel, image: image)
        
        navigationController.present(viewController, animated: true)
    }
    
    func showPasswortSetup(viewModel: RegisterViewModel) {
        let viewController = SetPasswordViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onSubmit = { [weak self] viewModel in
            self?.cardViewController.updateBackButton(title: "Passwort")
            self?.showEmailVerification(viewModel: viewModel)
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSocialMediaSetup(viewModel: RegisterViewModel) {
        let viewController = SetSocialMediaViewController.createWith(storyboard: .auth, viewModel: viewModel)

        viewController.onContinue = onSubmit
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func getTitle(for index: Int) -> String {
        switch index {
        case 2:
            return "Benutzername"
        case 3:
            return "E-Mail Adresse"
        case 4:
            return "E-Mail verifizieren"
        case 5:
            return "Passwort"
        case 6:
            return "Steckbrief"
        case 7:
            return "Soziales"
        default:
            return "Zurück"
        }
    }

}
