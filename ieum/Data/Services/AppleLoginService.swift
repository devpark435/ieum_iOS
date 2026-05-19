import Foundation
import Combine
import UIKit
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
    private weak var presentationAnchor: UIWindow?
    private var authorizationController: ASAuthorizationController?

    func login(presentationAnchor: UIWindow? = nil) -> AnyPublisher<AppleLoginCredential, Error> {
        let subject = PassthroughSubject<AppleLoginCredential, Error>()
        self.loginSubject = subject
        self.presentationAnchor = presentationAnchor

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.authorizationController = controller
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
        if let anchor = presentationAnchor {
            return anchor
        }

        let activeScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }

        let windows = activeScenes.flatMap { $0.windows }

        if let keyWindow = windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }

        if let anyWindow = windows.first(where: { $0.rootViewController != nil }) {
            return anyWindow
        }

        return ASPresentationAnchor()
    }
}
