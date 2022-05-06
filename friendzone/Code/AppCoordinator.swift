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
    
    func start(window: UIWindow) {
        self.window = window
        
        mainCoordinator.start()
        
        mainCoordinator.loginRequired = { [weak self] in
            self?.checkCredentials(animated: true)
        }
        
        addChild(mainCoordinator)
        
        window.rootViewController = mainCoordinator.rootViewController
        window.makeKeyAndVisible()
        
        printRootDebugStructure()
        
        checkCredentials(animated: false)
    }
    
    func checkCredentials(animated: Bool = true) {
        if Auth.auth().currentUser == nil {
            // not logged in
            presentLogin(animated: animated)
        }
    }
    
    func presentMain() {
        childCoordinators.removeAll()
        let coordinator = MainCoordinator()
        coordinator.start()
        
        coordinator.loginRequired = { [weak self] in
            self?.checkCredentials(animated: true)
        }
        
        addChild(coordinator)
        window.rootViewController = coordinator.rootViewController
    }
    
    var loginVisible: Bool {
        childCoordinators.contains { $0 is AuthCoordinator }
    }
    
    private func presentLogin(animated: Bool) {
        guard !loginVisible else { return }
        
        let coordinator = AuthCoordinator()
        
        coordinator.onLogin = { [weak self] in
            self?.presentMain()
        }
        
        coordinator.start()
        
        addChild(coordinator)
        window.rootViewController = coordinator.rootViewController
    }
    
    func reset(animated: Bool) {
        childCoordinators
            .filter { $0 !== mainCoordinator }
            .forEach { removeChild($0) }
        
        mainCoordinator.start()
        addChild(mainCoordinator)
        
        window.rootViewController = mainCoordinator.rootViewController
        window.makeKeyAndVisible()
        
        printRootDebugStructure()
    }
}
