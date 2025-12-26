import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func didFinishAuth()
}

final class AuthCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    weak var delegate: AuthCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLogin()
    }
    
    private func showLogin() {
        let viewController = LoginViewController()
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showSignUp() {
        let signUpNavController = UINavigationController()
        signUpNavController.modalPresentationStyle = .fullScreen
        
        let coordinator = SignUpCoordinator(navigationController: signUpNavController)
        coordinator.delegate = self
        addChild(coordinator)
        coordinator.start()
        
        navigationController.present(signUpNavController, animated: true)
    }
    
    func finish() {
        delegate?.didFinishAuth()
    }
}

extension AuthCoordinator: SignUpCoordinatorDelegate {
    func didFinishSignUp() {
        removeChild(childCoordinators.first!)
        finish()
    }
}

