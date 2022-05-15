//
//  NotificationCoordinator.swift
//  friendzone
//
//  Created by Paul Kühnel on 12.05.22.
//

import Foundation
import Toolbox

class NotificationCoordinator: NavigationCoordinator {
    
    override func start() {
        let viewModel = NotificationViewModel()
        let viewController = NotificationViewController.createWith(storyboard: .main, viewModel: viewModel)
        
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.setToolbarHidden(true, animated: true)
        navigationController.navigationBar.prefersLargeTitles = true
        
        viewController.title = "Neuigkeiten"
        
        push(viewController, animated: true)
    }
    
}
