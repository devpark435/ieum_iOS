import UIKit
import Combine

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let window: UIWindow
    private let authRepository: AuthRepository
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Development Mode
    /// 개발 모드: true로 설정하면 회원가입 과정을 건너뛰고 바로 메인 화면으로 이동
    /// 릴리즈 빌드 전에 반드시 false로 변경해야 합니다.
    private let isDevelopmentMode: Bool = false
    
    init(window: UIWindow, authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.window = window
        self.navigationController = UINavigationController()
        self.authRepository = authRepository
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // 로그아웃 알림 관찰
        observeLogout()
        
        // 개발 모드인 경우 바로 메인 화면으로 이동
        if isDevelopmentMode {
            showMain()
        } else {
            showSplash()
        }
    }
    
    private func observeLogout() {
        NotificationCenter.default.publisher(for: .userDidLogout)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleLogout()
            }
            .store(in: &cancellables)
    }
    
    private func handleLogout() {
        // 네비게이션 스택 초기화
        navigationController = UINavigationController()
        window.rootViewController = navigationController
        childCoordinators.removeAll()
        
        // 로그인 화면으로 이동
        showAuth()
    }
    
    private func showSplash() {
        let coordinator = SplashCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        addChild(coordinator)
        coordinator.start()
    }
    
    private func checkAutoLogin() {
        // 토큰이 없으면 로그인 화면으로
        guard let _ = TokenManager.shared.getAccessToken() else {
            showAuth()
            return
        }
        
        // 토큰 검증 및 프로필 조회 (자동 로그인 시도)
        authRepository.getProfile()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    // 실패 시 (토큰 만료 등) 로그인 화면으로
                    // (Refresh Token 자동 갱신은 Interceptor에서 처리됨. 여기서 실패하면 갱신도 실패한 것)
                    self?.showAuth()
                }
            } receiveValue: { [weak self] profile in
                // 성공 시 필수 정보 확인
                let hasRequiredInfo = !profile.nickname.isEmpty &&
                                    profile.ageGroup != nil &&
                                    profile.sex != nil &&
                                    !profile.diagnoses.isEmpty
                
                if hasRequiredInfo {
                    self?.showMain()
                } else {
                    // 필수 정보 없으면 로그인(회원가입) 흐름 태움
                    // 사용자 경험상 "회원가입 미완료" 상태이므로 로그인 화면부터 시작하거나
                    // 바로 SignUpCoordinator를 띄울 수도 있지만,
                    // AuthCoordinator가 이를 처리하도록 로그인 화면으로 보내는 것이 안전함
                    self?.showAuth()
                }
            }
            .store(in: &cancellables)
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
        // 메인 화면으로 전환 시 네비게이션 스택 정리
        childCoordinators.removeAll()
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}

extension AppCoordinator: SplashCoordinatorDelegate {
    func didFinishSplash() {
        removeChild(childCoordinators.first!)
        // 스플래시 종료 후 자동 로그인 체크
        checkAutoLogin()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func didFinishAuth() {
        removeChild(childCoordinators.first!)
        showMain()
    }
}
