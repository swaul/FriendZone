//
//  NotificationViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 12.05.22.
//

import Foundation
import UIKit

class NotificationViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: NotificationViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    var viewModel: NotificationViewModel!
}
