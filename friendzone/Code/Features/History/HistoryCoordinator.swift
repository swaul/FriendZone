//
//  HistoryCoordinator.swift
//  friendzone
//
//  Created by Paul Kühnel on 01.05.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import Toolbox
import UIKit
import SFSafeSymbols

class HistoryCoordinator: NavigationCoordinator {
    
    override func start() {
        let viewModel = HistoryViewModel()
        let viewController = HistoryViewController.createWith(storyboard: .history, viewModel: viewModel)
        
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.navigationBar.prefersLargeTitles = true
        
        rootViewController.tabBarItem.image = UIImage(systemSymbol: .clockArrowCirclepath)
        
        viewController.title = "Gespeichert"
        
        push(viewController, animated: true)
    }
    
}
