//
//  YourZoneCoordinator.swift
//  friendzone
//
//  Created by Paul Kühnel on 01.05.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import UIKit
import Toolbox
import friendzoneKit
import SwiftUI
import SFSafeSymbols

class YourZoneCoordinator: NavigationCoordinator {
    
    // MARK: Start
    
    var loginRequired: (() -> Void)!
    var showProfile: (() -> Void)!
    
    override func start() {
        let viewModel = YourZoneViewModel()
        let viewController = YourZoneViewController.createWith(storyboard: .main, viewModel: viewModel)
        
        navigationController.setNavigationBarHidden(true, animated: true)
        
        viewController.title = "Your Zone"
        
        viewController.loginRequired = { [weak self] in
            self?.loginRequired()
        }
        
        viewController.onProfile = { [weak self] in
            self?.showProfile()
        }
        
        viewController.onNews = { [weak self] in
            self?.showNews()
        }
        
        rootViewController.tabBarItem.image = UIImage(systemSymbol: .house)
        
        push(viewController, animated: true)
    }
    
    func showNews() {
        let coordinator = NotificationCoordinator()
        coordinator.start()
        
        present(coordinator, animated: true)
    }
    
}
