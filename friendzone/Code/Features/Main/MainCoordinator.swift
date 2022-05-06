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
        
        let profile = ProfileCoordinator()
        profile.start()
        
        let history = HistoryCoordinator()
        history.start()
                
        tabBarController.viewControllers = [
            profile.rootViewController,
            yourZoneCoordinator.rootViewController,
            history.rootViewController
        ]
        
        tabBarController.selectedIndex = 1
    }
}
