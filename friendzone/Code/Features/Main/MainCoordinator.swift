import UIKit
import Toolbox
import friendzoneKit
import SwiftUI

class MainCoordinator: TabBarCoordinator {
    
    // MARK: Start
    
    var loginRequired: (() -> Void)!
    
    var yourZoneCoordinator = YourZoneCoordinator()
    
    override func start() {
        addChild(yourZoneCoordinator)
        yourZoneCoordinator.start()
        
        yourZoneCoordinator.loginRequired = { [weak self] in
            self?.loginRequired()
        }
        
        yourZoneCoordinator.showProfile = { [weak self] in
            self?.tabBarController.selectedIndex = 0
        }
        
        let profile = ProfileCoordinator()
        profile.start()
        
        profile.onSignOut = { [weak self] in
            self?.loginRequired()
        }
        
        let history = HistoryCoordinator()
        history.start()
    
        yourZoneCoordinator.onLoaded = { [weak self] complete in
            profile.updateBadge(count: complete ? nil : 1)
        }
        
        tabBarController.viewControllers = [
            profile.rootViewController,
            yourZoneCoordinator.rootViewController,
            history.rootViewController
        ]
        
        tabBarController.selectedIndex = 1
    }
}
