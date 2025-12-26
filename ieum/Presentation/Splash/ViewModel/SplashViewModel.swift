import Foundation
import Combine

final class SplashViewModel: ObservableObject {
    // Navigation Events
    let navigateToLogin = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 2초 후 로그인 화면으로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigateToLogin.send()
        }
    }
}

