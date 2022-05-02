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
    
    override func start() {
        let viewModel = YourZoneViewModel()
        let viewController = YourZoneViewController.createWith(storyboard: .main, viewModel: viewModel)
        
        navigationController.setNavigationBarHidden(true, animated: true)
        
        viewController.loginRequired = { [weak self] in
            self?.presentLogin(animated: true)
        }
        
        rootViewController.tabBarItem.image = UIImage(systemSymbol: .house)
        
        push(viewController, animated: true)
    }
    
    private func presentLogin(animated: Bool) {
        let coordinator = AuthCoordinator()
        
        coordinator.start()
        
        addChild(coordinator)
        present(coordinator.rootViewController, animated: animated, completion: nil)
    }
}
