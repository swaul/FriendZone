import UIKit
import Toolbox
import friendzoneKit
import SwiftUI

class MainCoordinator: TabBarCoordinator {
    
    // MARK: Start
    
    var yourZoneCoordinator = YourZoneCoordinator()
    
    override func start() {
        addChild(yourZoneCoordinator)
        yourZoneCoordinator.start()
        
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
    
    private func presentLogin(animated: Bool) {
        let coordinator = AuthCoordinator()
        
        coordinator.start()
        
        addChild(coordinator)
        present(coordinator, animated: animated, completion: nil)
    }
}
