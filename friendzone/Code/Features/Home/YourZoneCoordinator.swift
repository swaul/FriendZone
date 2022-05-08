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
    
    override func start() {
        let viewModel = YourZoneViewModel()
        let viewController = YourZoneViewController.createWith(storyboard: .main, viewModel: viewModel)
        
        navigationController.setNavigationBarHidden(true, animated: true)
        
        viewController.loginRequired = { [weak self] in
            self?.loginRequired()
        }
        
        rootViewController.tabBarItem.image = UIImage(systemSymbol: .house)
        
        push(viewController, animated: true)
    }
    
}
