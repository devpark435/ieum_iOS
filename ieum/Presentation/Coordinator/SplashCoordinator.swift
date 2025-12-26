import UIKit

protocol SplashCoordinatorDelegate: AnyObject {
    func didFinishSplash()
}

final class SplashCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    weak var delegate: SplashCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = SplashViewController()
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func finish() {
        delegate?.didFinishSplash()
    }
}

