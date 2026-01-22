import Foundation
import Combine
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon

enum KakaoLoginError: Error {
    case unknown
    case clientFailure
    case tokenNotFound
}

final class KakaoLoginService {
    func login() -> AnyPublisher<String, Error> {
        return Future { promise in
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                    if let error = error {
                        promise(.failure(error))
                        print("Error Code: \(error)")
        print("Error Description: \(error.localizedDescription)")
                    } else {
                        if let token = oauthToken?.accessToken {
                            promise(.success(token))
                        } else {
                            promise(.failure(KakaoLoginError.tokenNotFound))
                        }
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        if let token = oauthToken?.accessToken {
                            promise(.success(token))
                        } else {
                            promise(.failure(KakaoLoginError.tokenNotFound))
                        }
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
