import UIKit
import Combine

protocol MyPageCoordinatorDelegate: AnyObject {
    // 마이페이지 흐름 종료 시 (필요 시)
}

final class MyPageCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    weak var delegate: MyPageCoordinatorDelegate?
    private weak var viewModel: MyPageViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = MyPageViewModel()
        let postsViewModel = MyPostsViewModel()
        self.viewModel = viewModel
        
        // Setup navigation actions
        viewModel.didTapEditProfile
            .sink { [weak self] in
                self?.showProfileEdit()
            }
            .store(in: &cancellables)
            
        viewModel.didTapInfoSection
            .sink { [weak self] sectionType in
                guard let self = self, let profile = viewModel.userProfile else { return }
                self.showEditSection(sectionType: sectionType, profile: profile)
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
    
    func showEditSection(sectionType: InfoSectionType, profile: UserProfile) {
        switch sectionType {
        case .diagnosis:
            showEditDiagnosis(profile: profile)
        case .surgery:
            showEditSurgery(profile: profile)
        case .chemotherapy:
            showEditChemotherapy(profile: profile)
        case .radiation:
            showEditRadiation(profile: profile)
        case .ageGroup:
            showEditAgeGroup(profile: profile)
        case .residence:
            showEditRegion(profile: profile)
        }
    }
    
    func showEditDiagnosis(profile: UserProfile) {
        let editVC = SignUpStep4ViewController(
            initialDiagnoses: profile.diagnoses,
            onComplete: { [weak self] diagnoses in
                guard let self = self, let viewModel = self.viewModel else { return }
                let request = viewModel.createUpdateRequest(from: profile, updatingDiagnoses: diagnoses)
                viewModel.updateProfile(request)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
                    .store(in: &self.cancellables)
                self.navigationController.popViewController(animated: true)
            }
        )
        editVC.coordinator = self
        editVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(editVC, animated: true)
    }
    
    func showEditAgeGroup(profile: UserProfile) {
        let editVC = SignUpStep5ViewController(
            initialAgeGroup: profile.ageGroup,
            onComplete: { [weak self] ageGroup in
                guard let self = self, let viewModel = self.viewModel else { return }
                let request = viewModel.createUpdateRequest(from: profile, updatingAgeGroup: ageGroup)
                viewModel.updateProfile(request)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
                    .store(in: &self.cancellables)
                self.navigationController.popViewController(animated: true)
            }
        )
        editVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(editVC, animated: true)
    }
    
    func showEditRegion(profile: UserProfile) {
        let editVC = SignUpStep6ViewController(
            initialResidenceArea: profile.residenceArea,
            onComplete: { [weak self] residenceArea in
                guard let self = self, let viewModel = self.viewModel else { return }
                let request = viewModel.createUpdateRequest(from: profile, updatingResidenceArea: residenceArea)
                viewModel.updateProfile(request)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
                    .store(in: &self.cancellables)
                self.navigationController.popViewController(animated: true)
            }
        )
        editVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(editVC, animated: true)
    }
    
    func showStageSelection(cancerName: String, onSelect: @escaping (String) -> Void) {
        let viewController = StageSelectionViewController(cancerName: cancerName)
        viewController.onSelect = onSelect
        navigationController.present(viewController, animated: true)
    }
    
    func showEditSurgery(profile: UserProfile) {
        // TODO: 수술 이력 수정 UI 구현 필요
    }
    
    func showEditChemotherapy(profile: UserProfile) {
        // TODO: 항암 이력 수정 UI 구현 필요
    }
    
    func showEditRadiation(profile: UserProfile) {
        // TODO: 방사선 이력 수정 UI 구현 필요
    }
}
