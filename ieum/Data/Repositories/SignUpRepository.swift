import Foundation
import Combine
import Alamofire

protocol SignUpRepository {
    func register(request: UserRegistrationRequest) -> AnyPublisher<UserRegistrationResponse, Error>
}

final class SignUpRepositoryImpl: SignUpRepository {
    private let apiService = APIService.shared
    
    func register(request: UserRegistrationRequest) -> AnyPublisher<UserRegistrationResponse, Error> {
        let endpoint = "/api/v1/users/register"
        
        return Future<UserRegistrationResponse, Error> { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    let response: UserRegistrationResponse = try await self.apiService.request(
                        endpoint,
                        method: .post,
                        parameters: request
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
