//
//  ProfileCoordinator.swift
//  friendzone
//
//  Created by Paul Kühnel on 01.05.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import Toolbox
import UIKit
import SFSafeSymbols

class ProfileCoordinator: NavigationCoordinator {
    
    override func start() {
        let viewModel = ProfileViewModel()
        let viewController = ProfileViewController.createWith(storyboard: .profile, viewModel: viewModel)
        
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.navigationBar.prefersLargeTitles = true
        
        rootViewController.tabBarItem.image = UIImage(systemSymbol: .person)

        viewController.onImageTapped = { image in
            self.showImageCropper(image: image, viewModel: viewModel)
        }
        
        push(viewController, animated: true)
    }
    
    func showImageCropper(image: UIImage, viewModel: ProfileViewModel) {
        let viewController = ImageCropperViewController.createWith(storyboard: .auth, viewModel: viewModel, image: image)
        
        present(viewController, animated: true)
    }
    
}
