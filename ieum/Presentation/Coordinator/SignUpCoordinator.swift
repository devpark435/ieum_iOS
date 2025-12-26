import UIKit

protocol SignUpCoordinatorDelegate: AnyObject {
    func didFinishSignUp()
}

final class SignUpCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    weak var delegate: SignUpCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showStep1()
    }
    
    func showStep1() {
        let viewController = SignUpStep1ViewController()
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func showStep2() {
        let viewController = SignUpStep2ViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showStep3() {
        let viewController = SignUpStep3ViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
        navigationController.setNavigationBarHidden(false, animated: true)
    }
    
    func showStep4() {
        let viewController = SignUpStep4ViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showStep5() {
        let viewController = SignUpStep5ViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showStep6() {
        let viewController = SignUpStep6ViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showStep7() {
        let viewController = SignUpStep7ViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showComplete() {
        let viewController = SignUpCompleteViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showStageSelection(cancerName: String, onSelect: @escaping (String) -> Void) {
        let viewController = StageSelectionViewController(cancerName: cancerName)
        viewController.onSelect = onSelect
        navigationController.present(viewController, animated: true)
    }
    
    func finish() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.delegate?.didFinishSignUp()
        }
    }
}

