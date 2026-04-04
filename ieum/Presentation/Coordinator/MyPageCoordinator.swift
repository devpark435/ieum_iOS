import UIKit
import Combine

protocol MyPageCoordinatorDelegate: AnyObject {
    // 마이페이지 흐름 종료 시 (필요 시)
}

// 로그아웃/회원탈퇴 시 로그인 화면 전환을 위한 Notification
extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}

final class MyPageCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    weak var delegate: MyPageCoordinatorDelegate?
    private weak var viewModel: MyPageViewModel?
    private var cancellables = Set<AnyCancellable>()
    private let authRepository: AuthRepository = AuthRepositoryImpl()
    
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
        
        viewModel.didTapEditNickname
            .sink { [weak self] in
                guard let self = self, let profile = viewModel.userProfile else { return }
                self.showEditNickname(profile: profile)
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
    
    func showEditNickname(profile: UserProfile) {
        let editVC = NicknameEditViewController(
            currentNickname: profile.nickname,
            onComplete: { [weak self] nickname in
                guard let self = self, let viewModel = self.viewModel else { return }
                let request = viewModel.createUpdateRequest(from: profile, updatingNickname: nickname)
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
        let editVC = SurgeryHistoryViewController(
            initialSurgeries: profile.surgery,
            onComplete: { [weak self] surgeries, isPrivate in
                guard let self = self, let viewModel = self.viewModel else { return }
                let request = viewModel.createUpdateRequest(
                    from: profile,
                    updatingSurgery: surgeries.isEmpty ? [] : surgeries
                )
                let updatedRequest = UpdateProfileRequest(
                    nickname: nil,
                    diagnoses: request.diagnoses,
                    surgery: surgeries.isEmpty ? [] : surgeries,
                    chemotherapy: request.chemotherapy,
                    radiationTherapy: request.radiationTherapy,
                    ageGroup: request.ageGroup,
                    residenceArea: request.residenceArea,
                    hospitalArea: request.hospitalArea,
                    sexVisible: request.sexVisible,
                    diagnosesVisible: request.diagnosesVisible,
                    surgeryVisible: isPrivate ? false : request.surgeryVisible,
                    chemotherapyVisible: request.chemotherapyVisible,
                    radiationTherapyVisible: request.radiationTherapyVisible,
                    ageGroupVisible: request.ageGroupVisible,
                    residenceAreaVisible: request.residenceAreaVisible,
                    hospitalAreaVisible: request.hospitalAreaVisible
                )
                viewModel.updateProfile(updatedRequest)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
                    .store(in: &self.cancellables)
            }
        )
        editVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(editVC, animated: true)
    }
    
    func showEditChemotherapy(profile: UserProfile) {
        let editVC = ChemotherapyHistoryViewController(
            initialChemotherapies: profile.chemotherapy,
            onComplete: { [weak self] chemotherapies, isPrivate in
                guard let self = self, let viewModel = self.viewModel else { return }
                let request = viewModel.createUpdateRequest(
                    from: profile,
                    updatingChemotherapy: chemotherapies.isEmpty ? [] : chemotherapies
                )
                let updatedRequest = UpdateProfileRequest(
                    nickname: nil,
                    diagnoses: request.diagnoses,
                    surgery: request.surgery,
                    chemotherapy: chemotherapies.isEmpty ? [] : chemotherapies,
                    radiationTherapy: request.radiationTherapy,
                    ageGroup: request.ageGroup,
                    residenceArea: request.residenceArea,
                    hospitalArea: request.hospitalArea,
                    sexVisible: request.sexVisible,
                    diagnosesVisible: request.diagnosesVisible,
                    surgeryVisible: request.surgeryVisible,
                    chemotherapyVisible: isPrivate ? false : request.chemotherapyVisible,
                    radiationTherapyVisible: request.radiationTherapyVisible,
                    ageGroupVisible: request.ageGroupVisible,
                    residenceAreaVisible: request.residenceAreaVisible,
                    hospitalAreaVisible: request.hospitalAreaVisible
                )
                viewModel.updateProfile(updatedRequest)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
                    .store(in: &self.cancellables)
            }
        )
        editVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(editVC, animated: true)
    }
    
    func showEditRadiation(profile: UserProfile) {
        let editVC = RadiationHistoryViewController(
            initialRadiations: profile.radiationTherapy,
            onComplete: { [weak self] radiations, isPrivate in
                guard let self = self, let viewModel = self.viewModel else { return }
                let request = viewModel.createUpdateRequest(
                    from: profile,
                    updatingRadiationTherapy: radiations.isEmpty ? [] : radiations
                )
                let updatedRequest = UpdateProfileRequest(
                    nickname: nil,
                    diagnoses: request.diagnoses,
                    surgery: request.surgery,
                    chemotherapy: request.chemotherapy,
                    radiationTherapy: radiations.isEmpty ? [] : radiations,
                    ageGroup: request.ageGroup,
                    residenceArea: request.residenceArea,
                    hospitalArea: request.hospitalArea,
                    sexVisible: request.sexVisible,
                    diagnosesVisible: request.diagnosesVisible,
                    surgeryVisible: request.surgeryVisible,
                    chemotherapyVisible: request.chemotherapyVisible,
                    radiationTherapyVisible: isPrivate ? false : request.radiationTherapyVisible,
                    ageGroupVisible: request.ageGroupVisible,
                    residenceAreaVisible: request.residenceAreaVisible,
                    hospitalAreaVisible: request.hospitalAreaVisible
                )
                viewModel.updateProfile(updatedRequest)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { _ in }
                    )
                    .store(in: &self.cancellables)
            }
        )
        editVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(editVC, animated: true)
    }
    
    // MARK: - Settings
    
    func showSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.delegate = self
        settingsVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(settingsVC, animated: true)
    }
}

// MARK: - SettingsViewControllerDelegate

extension MyPageCoordinator: SettingsViewControllerDelegate {
    func didTapPrivacyPolicy() {
        let privacyVC = PrivacyPolicyViewController()
        privacyVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(privacyVC, animated: true)
    }
    
    func didTapDeleteAccount() {
        authRepository.deleteAccount()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Delete account error: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.handleLogout()
            }
            .store(in: &cancellables)
    }
    
    func didTapLogout() {
        handleLogout()
    }
    
    private func handleLogout() {
        // 토큰 삭제
        TokenManager.shared.clearTokens()
        
        // 로그인 화면으로 전환 알림
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
}
