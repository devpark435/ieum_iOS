import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    // Inputs
    let didTapKakaoLogin = PassthroughSubject<Void, Never>()
    let didTapAppleLogin = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published var isLoading = false
    @Published var error: Error?
    
    // Navigation Events
    let navigateToSignUp = PassthroughSubject<Void, Never>()
    let navigateToMain = PassthroughSubject<Void, Never>()
    
    private let kakaoLoginService: KakaoLoginService
    private let appleLoginService: AppleLoginService
    private let authRepository: AuthRepository
    private let tokenManager = TokenManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(kakaoLoginService: KakaoLoginService = KakaoLoginService(),
         appleLoginService: AppleLoginService = AppleLoginService(),
         authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.kakaoLoginService = kakaoLoginService
        self.appleLoginService = appleLoginService
        self.authRepository = authRepository
        bindInputs()
    }
    
    private func bindInputs() {
        didTapKakaoLogin
            .sink { [weak self] in
                self?.loginWithKakao()
            }
            .store(in: &cancellables)
        
        didTapAppleLogin
            .sink { [weak self] in
                self?.loginWithApple()
            }
            .store(in: &cancellables)
    }
    
    private func loginWithKakao() {
        isLoading = true
        
        kakaoLoginService.login()
            .flatMap { [weak self] token -> AnyPublisher<AppLoginResponse, Error> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.authRepository.loginWithKakao(accessToken: token)
            }
            .flatMap { [weak self] response -> AnyPublisher<Bool, Error> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.handleLoginResponse(response)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] isProfileComplete in
                self?.handleNavigation(isProfileComplete: isProfileComplete)
            }
            .store(in: &cancellables)
    }
    
    private func loginWithApple() {
        isLoading = true
        
        appleLoginService.login()
            .flatMap { [weak self] token -> AnyPublisher<AppLoginResponse, Error> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.authRepository.loginWithApple(accessToken: token)
            }
            .flatMap { [weak self] response -> AnyPublisher<Bool, Error> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.handleLoginResponse(response)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] isProfileComplete in
                self?.handleNavigation(isProfileComplete: isProfileComplete)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    private func handleLoginResponse(_ response: AppLoginResponse) -> AnyPublisher<Bool, Error> {
        // 1. 토큰 저장
        self.tokenManager.save(accessToken: response.accessToken, refreshToken: response.refreshToken)
        SignUpDataManager.shared.reset()
        
        // 2. isRegistered가 false면 바로 회원가입으로
        if !response.user.isRegistered {
            return Just(false).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        // 3. isRegistered가 true여도 필수 정보 확인을 위해 프로필 조회
        return self.authRepository.getProfile()
            .map { profile in
                // 필수 정보 검증: 닉네임, 나이대, 성별, 진단명이 모두 있어야 함
                let hasRequiredInfo = !profile.nickname.isEmpty &&
                profile.ageGroup != nil &&
                profile.sex != nil &&
                !profile.diagnoses.isEmpty
                return hasRequiredInfo
            }
            .eraseToAnyPublisher()
    }
    
    private func handleNavigation(isProfileComplete: Bool) {
        if isProfileComplete {
            self.navigateToMain.send()
        } else {
            self.navigateToSignUp.send()
        }
    }
}
