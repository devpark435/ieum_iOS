import Alamofire
import Foundation

final class AuthInterceptor: RequestInterceptor {
    private let tokenManager = TokenManager.shared
    private let baseURL: String
    
    init() {
        self.baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String ?? ""
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        // 토큰이 필요 없는 엔드포인트 예외 처리
        if let urlString = request.url?.absoluteString {
            if urlString.contains("/auth/oauth/kakao") ||
               urlString.contains("/auth/oauth/apple") ||
               urlString.contains("/auth/refresh") {
                completion(.success(request))
                return
            }
        }
        
        if let token = tokenManager.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        // 무한 루프 방지: 이미 갱신 요청이었다면 중단
        if let urlString = request.task?.originalRequest?.url?.absoluteString, urlString.contains("/auth/refresh") {
            completion(.doNotRetry)
            return
        }
        
        guard let refreshToken = tokenManager.getRefreshToken() else {
            completion(.doNotRetry)
            return
        }
        
        // 토큰 갱신 요청 (AF Session 사용시 순환 참조 주의 -> 별도 요청 생성)
        let refreshUrl = "\(baseURL)/api/v1/auth/refresh"
        let parameters = ["refreshToken": refreshToken]
        
        AF.request(refreshUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: AppTokenResponse.self) { [weak self] response in
                switch response.result {
                case .success(let data):
                    self?.tokenManager.save(accessToken: data.accessToken, refreshToken: data.refreshToken)
                    completion(.retry)
                case .failure:
                    self?.tokenManager.clearTokens()
                    NotificationCenter.default.post(name: .userDidLogout, object: nil)
                    completion(.doNotRetry)
                }
            }
    }
}
