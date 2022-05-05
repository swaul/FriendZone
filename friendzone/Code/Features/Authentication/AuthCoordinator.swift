import UIKit
import Toolbox

class AuthCoordinator: NavigationCoordinator {
    
    // MARK: Interface
    
    var onLogin: (() -> Void)!

    // MARK: - Init
    
    override init(navigationController: UINavigationController = UINavigationController()) {
        super.init(navigationController: navigationController)
        navigationController.setNeedsStatusBarAppearanceUpdate()
        navigationController.isModalInPresentation = true
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: Start
    
    override func start() {
        let viewController = WelcomeViewController.createWith(storyboard: .auth)
        
        viewController.onLogin = { [weak self] in
            self?.showLogin()
        }
        
        viewController.onRegister = { [weak self] in
            self?.showRegistration()
        }
        
        push(viewController, animated: true)
    }
    
    func showLogin() {
        
    }
    
    func showRegistration() {
        let coordinator = RegisterCoordinator()
        coordinator.start()
        
        coordinator.onDismiss = { [weak self] in
            self?.dismissChildCoordinator(animated: true)
        }
        
        present(coordinator, animated: true)
    }
}
