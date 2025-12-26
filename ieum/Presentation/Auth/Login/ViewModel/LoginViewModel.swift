import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    // Inputs
    let didTapKakaoLogin = PassthroughSubject<Void, Never>()
    
    // Navigation Events
    let navigateToSignUp = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        didTapKakaoLogin
            .sink { [weak self] in
                // TODO: 카카오 로그인 SDK 연동
                print("카카오 로그인 버튼 탭")
                self?.navigateToSignUp.send()
            }
            .store(in: &cancellables)
    }
}

