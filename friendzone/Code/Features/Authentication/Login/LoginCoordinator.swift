//
//  LoginCoordinator.swift
//  friendzone
//
//  Created by Paul Kühnel on 05.05.22.
//

import Foundation

class LoginCoordinator: CardCoordinator {
    
    var onLogin: (() -> Void)!
    var onRegister: (() -> Void)!
    
    override init() {
        super.init()
        
        cardViewController.onBack = { [weak self] in
            self?.onDismiss()
        }
        
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    override func start() {
        let viewModel = LoginViewModel()
        let viewController = LoginViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onLogin = { [weak self] in
            self?.onLogin()
        }
        
        viewController.onRegister = { [weak self] in
            self?.onRegister()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
