import Foundation
import Combine
import Alamofire

protocol AuthRepository {
    func loginWithKakao(accessToken: String) -> AnyPublisher<AppLoginResponse, Error>
    func loginWithApple(accessToken: String) -> AnyPublisher<AppLoginResponse, Error>
    func refresh(refreshToken: String) -> AnyPublisher<AppTokenResponse, Error>
    func getProfile() -> AnyPublisher<UserProfile, Error>
}

final class AuthRepositoryImpl: AuthRepository {
    private let apiService = APIService.shared
    
    func loginWithKakao(accessToken: String) -> AnyPublisher<AppLoginResponse, Error> {
        let endpoint = "/api/v1/auth/oauth/kakao"
        let parameters = AppLoginRequest(accessToken: accessToken)
        
        return Future<AppLoginResponse, Error> { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    let response: AppLoginResponse = try await self.apiService.request(
                        endpoint,
                        method: .post,
                        parameters: parameters
                    )
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loginWithApple(accessToken: String) -> AnyPublisher<AppLoginResponse, Error> {
        let endpoint = "/api/v1/auth/oauth/apple"
        let parameters = AppLoginRequest(accessToken: accessToken)
        
        return Future<AppLoginResponse, Error> { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    let response: AppLoginResponse = try await self.apiService.request(
                        endpoint,
                        method: .post,
                        parameters: parameters
                    )
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func refresh(refreshToken: String) -> AnyPublisher<AppTokenResponse, Error> {
        let endpoint = "/api/v1/auth/refresh"
        let parameters = AppTokenRefreshRequest(refreshToken: refreshToken)
        
        return Future<AppTokenResponse, Error> { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    let response: AppTokenResponse = try await self.apiService.request(
                        endpoint,
                        method: .post,
                        parameters: parameters
                    )
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getProfile() -> AnyPublisher<UserProfile, Error> {
        let endpoint = "/api/v1/users/profile"
        
        return Future<UserProfile, Error> { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    let response: UserProfile = try await self.apiService.request(
                        endpoint,
                        method: .get
                    )
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
