import UIKit
import Toolbox

class AuthCoordinator: NavigationCoordinator {
    
    var welcomeViewController: WelcomeViewController!
    
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
        welcomeViewController = WelcomeViewController.createWith(storyboard: .auth)
        
        welcomeViewController.onLogin = { [weak self] in
            self?.showLogin()
        }
        
        welcomeViewController.onRegister = { [weak self] in
            self?.showRegistration()
        }
        
        welcomeViewController.onRegistered = { [weak self] in
            self?.onLogin()
        }
        
        push(welcomeViewController, animated: true)
    }
    
    func showLogin() {
        let coordinator = LoginCoordinator()
        coordinator.start()
        
        coordinator.onDismiss = { [weak self] in
            self?.dismissChildCoordinator(animated: true)
        }
        
        coordinator.onLogin = { [weak self] in
            self?.onLogin()
        }
        
        present(coordinator, animated: true)
    }
    
    func showRegistration() {
        let coordinator = RegisterCoordinator()
        coordinator.start()
        
        coordinator.onDismiss = { [weak self] in
            self?.dismissChildCoordinator(animated: true)
        }
        
        coordinator.onSubmit = { [weak self] in
            self?.showSuccessfulRegistration()
        }
        
        present(coordinator, animated: true)
    }
    
    func showSuccessfulRegistration() {
        welcomeViewController.showSuccessfulRegistration()
        self.dismissChildCoordinator(animated: true)
    }
}
