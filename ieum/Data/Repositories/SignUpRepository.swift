import Foundation
import Combine
import Alamofire

protocol SignUpRepository {
    func register(request: UserRegistrationRequest) -> AnyPublisher<UserRegistrationResponse, Error>
}

final class SignUpRepositoryImpl: SignUpRepository {
    private let apiService = APIService.shared
    
    func register(request: UserRegistrationRequest) -> AnyPublisher<UserRegistrationResponse, Error> {
        let url = "\(apiService.baseURL)/api/v1/users/register"
        
        return Future<UserRegistrationResponse, Error> { [weak self] promise in
            guard let self = self else { return }
            
            Task {
                do {
                    let value = try await self.apiService.session.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default)
                        .validate()
                        .serializingDecodable(UserRegistrationResponse.self)
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
