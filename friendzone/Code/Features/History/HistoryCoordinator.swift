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
        rootViewController.tabBarItem.image = UIImage(systemSymbol: .clockArrowCirclepath)
    }
    
}
