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
        let viewModel = LoginViewModel()
        let viewController = LoginViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onLogin = { [weak self] in
            
        }
        
        viewController.onRegister = { [weak self] in
            self?.showRegistration()
        }
        
        push(viewController, animated: true)
    }
    
    func showRegistration() {
        let coordinator = RegisterCoordinator()
        coordinator.start()
        present(coordinator, animated: true)
    }
}
