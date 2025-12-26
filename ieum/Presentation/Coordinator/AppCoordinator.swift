import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        showSplash()
    }
    
    private func showSplash() {
        let coordinator = SplashCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        addChild(coordinator)
        coordinator.start()
    }
    
    private func showAuth() {
        let coordinator = AuthCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        addChild(coordinator)
        coordinator.start()
    }
    
    private func showMain() {
        // TODO: MainTabBarController 등으로 교체
        let mainVC = ViewController()
        window.rootViewController = mainVC
        finish()
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}

extension AppCoordinator: SplashCoordinatorDelegate {
    func didFinishSplash() {
        removeChild(childCoordinators.first!)
        showAuth()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func didFinishAuth() {
        removeChild(childCoordinators.first!)
        showMain()
    }
}

