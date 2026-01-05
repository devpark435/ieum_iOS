import UIKit

protocol FeedCoordinatorDelegate: AnyObject {
    // Feed 흐름이 끝났을 때 (필요시)
}

final class FeedCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    weak var delegate: FeedCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = FeedViewModel()
        let viewController = FeedViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showTreatmentRecord() {
        // 치료 기록 작성 화면으로 이동 (풀스크린 모달)
        let viewController = TreatmentRecordViewController()
        viewController.modalPresentationStyle = .fullScreen
        // TreatmentRecordViewController에 코디네이터나 델리게이트 주입 필요 시 여기서 수행
        // 예: viewController.coordinator = self (만약 FeedCoordinator가 계속 관리한다면)
        
        navigationController.present(viewController, animated: true)
    }
    
    func showDailyRecord() {
        // TODO: 일상 기록 화면 이동 구현
        print("일상 기록 화면으로 이동")
    }
    
    func showComments(postId: Int) {
        let viewModel = CommentViewModel(postId: postId)
        let viewController = CommentViewController(viewModel: viewModel)
        // DimmedViewController handles presentation style (.overFullScreen)
        // Custom transition is handled inside CommentViewController
        navigationController.present(viewController, animated: false)
    }
}
