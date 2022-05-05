//
//  LoginCoordinator.swift
//  friendzone
//
//  Created by Paul Kühnel on 05.05.22.
//

import Foundation

class LoginCoordinator: CardCoordinator {
    
    var onSubmit: (() -> Void)!
    
    override init() {
        super.init()
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    override func start() {
//        let viewModel = LoginViewModel()
//        let viewController = LoginViewController.createWith(storyboard: .auth, viewModel: viewModel)
//        
//        navigationController.pushViewController(viewController, animated: true)
    }
}
