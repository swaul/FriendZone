import UIKit
import Toolbox

class AuthCoordinator: NavigationCoordinator {
    
    // MARK: Interface
    
    var onLogin: (() -> Void)!

    // MARK: - Init
    
    override init(navigationController: UINavigationController = UINavigationController()) {
        super.init(navigationController: navigationController)
        
        navigationController.isModalInPresentation = true
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: Start
    
    override func start() {
        let viewModel = LoginViewModel()
        let viewController = LoginViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onLogin = { [weak self] in
            self?.popViewController(animated: true)
        }

        viewController.onRegister = { [weak self] email in
            self?.showRegistration(email: email)
        }
        
        push(viewController, animated: true)
    }
    
    func showRegistration(email: String) {
        let viewController = RegisterViewController.createWith(storyboard: .auth, viewModel: RegisterViewModel(email: email))
        
        viewController.onContinue = { [weak self] viewModel in
            self?.showImagePicker(viewModel: viewModel)
        }
        
        viewController.onBack = { [weak self] in
            self?.popViewController(animated: true)
        }
        
        push(viewController, animated: true)
    }
    
    func showImagePicker(viewModel: RegisterViewModel) {
        let viewController = SetProfilePictureViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onBack = { [weak self] in
            self?.popViewController(animated: true)
        }
        
        viewController.onContinue = { [weak self] viewModel in
            self?.showSocialMediaSetup(viewModel: viewModel)
        }
        
        push(viewController, animated: true)
    }
    
    func showSocialMediaSetup(viewModel: RegisterViewModel) {
        let viewController = SetSocialMediaViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onBack = { [weak self] in
            self?.popViewController(animated: true)
        }
        
        viewController.onContinue = { [weak self] viewModel in
            self?.showPasswortSetup(viewModel: viewModel)
        }
        
        push(viewController, animated: true)
    }
    
    func showPasswortSetup(viewModel: RegisterViewModel) {
        let viewController = SetPasswordViewController.createWith(storyboard: .auth, viewModel: viewModel)
        
        viewController.onBack = { [weak self] in
            self?.popViewController(animated: true)
        }
        
        viewController.onSubmit = { [weak self] in
            self?.popToRoot(animated: true)
        }
        
        push(viewController, animated: true)
    }
}
