import UIKit
import Combine

protocol MyPageCoordinatorDelegate: AnyObject {
    // 마이페이지 흐름 종료 시 (필요 시)
}

final class MyPageCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    weak var delegate: MyPageCoordinatorDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = MyPageViewModel()
        let postsViewModel = MyPostsViewModel()
        
        // Setup navigation actions
        viewModel.didTapEditProfile
            .sink { [weak self] in
                self?.showProfileEdit()
            }
            .store(in: &cancellables)
            
        viewModel.didTapInfoSection
            .sink { [weak self] sectionType in
                self?.showInfoDetail()
            }
            .store(in: &cancellables)
            
        let viewController = MyPageMainViewController(
            viewModel: viewModel,
            postsViewModel: postsViewModel,
            coordinator: self
        )
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showProfileEdit() {
        let editVC = ProfileEditViewController()
        editVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(editVC, animated: true)
    }
    
    func showInfoDetail() {
        let detailVC = InfoDetailViewController()
        detailVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    func showPostDetail(postId: Int) {
        print("Show Post Detail: \(postId)")
    }
}
