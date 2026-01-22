import Foundation
import Combine
import AuthenticationServices

enum AppleLoginError: Error {
    case unknown
    case tokenNotFound
}

final class AppleLoginService: NSObject {
    func login() -> AnyPublisher<String, Error> {
        // TODO: Apple 로그인 로직 구현 (ASAuthorizationController)
        // 현재는 구현 비워둠
        return Fail(error: AppleLoginError.unknown).eraseToAnyPublisher()
    }
}
