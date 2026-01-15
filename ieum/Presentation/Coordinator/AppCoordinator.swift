import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let window: UIWindow
    
    // MARK: - Development Mode
    /// 개발 모드: true로 설정하면 회원가입 과정을 건너뛰고 바로 메인 화면으로 이동
    /// 릴리즈 빌드 전에 반드시 false로 변경해야 합니다.
    private let isDevelopmentMode: Bool = false
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // 개발 모드인 경우 바로 메인 화면으로 이동
        if isDevelopmentMode {
            showMain()
        } else {
            showSplash()
        }
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
        let mainTabBarController = MainTabBarController()
        window.rootViewController = mainTabBarController
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

