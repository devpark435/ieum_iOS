import Foundation
import Combine
import Alamofire

protocol AuthRepository {
    func loginWithKakao(accessToken: String) -> AnyPublisher<AppLoginResponse, Error>
    func refresh(refreshToken: String) -> AnyPublisher<AppTokenResponse, Error>
}

final class AuthRepositoryImpl: AuthRepository {
    private let apiService = APIService.shared
    
    func loginWithKakao(accessToken: String) -> AnyPublisher<AppLoginResponse, Error> {
        let url = "\(apiService.baseURL)/api/v1/auth/oauth/kakao"
        let parameters = AppLoginRequest(accessToken: accessToken)
        
        return Future<AppLoginResponse, Error> { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    let value = try await self.apiService.session.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                        .validate()
                        .serializingDecodable(AppLoginResponse.self)
                        .value
                    promise(.success(value))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func refresh(refreshToken: String) -> AnyPublisher<AppTokenResponse, Error> {
        let url = "\(apiService.baseURL)/api/v1/auth/refresh"
        let parameters = AppTokenRefreshRequest(refreshToken: refreshToken)
        
        return Future<AppTokenResponse, Error> { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    let value = try await self.apiService.session.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                        .validate()
                        .serializingDecodable(AppTokenResponse.self)
                        .value
                    promise(.success(value))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
