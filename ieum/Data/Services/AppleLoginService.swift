import Foundation
import Combine
import AuthenticationServices

enum AppleLoginError: Error {
    case unknown
    case tokenNotFound
    case cancelled
}

struct AppleLoginCredential {
    let identityToken: String
    let authorizationCode: String
}

final class AppleLoginService: NSObject {
    private var loginSubject: PassthroughSubject<AppleLoginCredential, Error>?

    func login() -> AnyPublisher<AppleLoginCredential, Error> {
        let subject = PassthroughSubject<AppleLoginCredential, Error>()
        self.loginSubject = subject

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()

        return subject.eraseToAnyPublisher()
    }
}

extension AppleLoginService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8),
              let authCodeData = credential.authorizationCode,
              let authorizationCode = String(data: authCodeData, encoding: .utf8) else {
            loginSubject?.send(completion: .failure(AppleLoginError.tokenNotFound))
            return
        }

        let appleCredential = AppleLoginCredential(
            identityToken: identityToken,
            authorizationCode: authorizationCode
        )
        loginSubject?.send(appleCredential)
        loginSubject?.send(completion: .finished)
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            loginSubject?.send(completion: .failure(AppleLoginError.cancelled))
        } else {
            loginSubject?.send(completion: .failure(error))
        }
    }
}

extension AppleLoginService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}
