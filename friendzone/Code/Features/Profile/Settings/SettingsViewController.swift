//
//  SettingsViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 27.05.22.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: SettingsViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    var viewModel: SettingsViewModel!
   
    
    
}
