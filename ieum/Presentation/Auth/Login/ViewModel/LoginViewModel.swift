import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    // Inputs
    let didTapKakaoLogin = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published var isLoading = false
    @Published var error: Error?
    
    // Navigation Events
    let navigateToSignUp = PassthroughSubject<Void, Never>()
    let navigateToMain = PassthroughSubject<Void, Never>()
    
    private let kakaoLoginService: KakaoLoginService
    private let authRepository: AuthRepository
    private let tokenManager = TokenManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(kakaoLoginService: KakaoLoginService = KakaoLoginService(),
         authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.kakaoLoginService = kakaoLoginService
        self.authRepository = authRepository
        bindInputs()
    }
    
    private func bindInputs() {
        didTapKakaoLogin
            .sink { [weak self] in
                self?.loginWithKakao()
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] response in
                self?.tokenManager.save(accessToken: response.accessToken, refreshToken: response.refreshToken)
                
                // 로그인 성공 시 회원가입 데이터 초기화
                SignUpDataManager.shared.reset()
                
                if response.user.isRegistered {
                    self?.navigateToMain.send()
                } else {
                    self?.navigateToSignUp.send()
                }
            }
            .store(in: &cancellables)
    }
}
