import friendzoneKit
import Combine
import Toolbox
import UIKit
import FirebaseAuth

class AppCoordinator: Coordinator {
    private var cancellable = Set<AnyCancellable>()
    
    static let shared = AppCoordinator()
    
    var window: UIWindow!
    let mainCoordinator = MainCoordinator()
    let authCoordinator = AuthCoordinator()
    
    func start(window: UIWindow) {
        self.window = window
        
        authCoordinator.start()
        addChild(authCoordinator)
        
        window.rootViewController = authCoordinator.rootViewController
        window.makeKeyAndVisible()
        
        printRootDebugStructure()
        
        checkCredentials(animated: false)
        
//        CredentialsController.shared.$currentCredentialsChanged
//            .sink { [weak self] isChanged in
//                if isChanged {
//                    self?.checkCredentials()
//                }
//            }
//            .store(in: &cancellable)
    }
    
    func checkCredentials(animated: Bool = true) {
        if Auth.auth().currentUser != nil {
            mainCoordinator.start()
            addChild(mainCoordinator)
            
            window.rootViewController = mainCoordinator.rootViewController
            window.makeKeyAndVisible()
        }
    }
    
    func reset(animated: Bool) {
        childCoordinators
            .filter { $0 !== mainCoordinator }
            .forEach { removeChild($0) }
        
        printRootDebugStructure()
    }
    
    private func presentLogin(animated: Bool) {
        let coordinator = AuthCoordinator()
        
        coordinator.onLogin = { [weak self] in
            self?.reset(animated: true)
        }
        
        coordinator.start()
        
        addChild(coordinator)
        window.topViewController()?.present(coordinator.rootViewController, animated: animated, completion: nil)
    }
}
