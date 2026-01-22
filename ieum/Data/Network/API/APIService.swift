import Alamofire
import Foundation
import Combine
import OSLog

final class APIService {
    static let shared = APIService()
    let session: Session
    
    private init() {
        let interceptor = AuthInterceptor()
        // APIRequestLogger는 더 이상 사용하지 않고 내부 메서드에서 직접 로깅
        session = Session(interceptor: interceptor)
    }
    
    var baseURL: String {
        return Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String ?? ""
    }
    
    /// 공통 비동기 요청 메서드 (Concurrency + Logging) - 파라미터 있음
    func request<T: Decodable, P: Encodable>(_ endpoint: String,
                                             method: HTTPMethod,
                                             parameters: P? = nil,
                                             encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> T {
        
        let fullURL = "\(baseURL)\(endpoint)"
        
        // 1. 요청 로그
        Logger.network.debug("🚀 [Request] \(method.rawValue) \(endpoint)")
        
        let request = session.request(fullURL, method: method, parameters: parameters, encoder: encoder)
            .validate()
        
        // 2. 응답 데이터 로깅 (디버그 모드에서만)
        #if DEBUG
        request.responseData { response in
            let statusCode = response.response?.statusCode ?? 0
            
            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                // JSON Pretty Print
                var logBody = jsonString
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                   let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    logBody = prettyString
                }
                
                Logger.network.debug("""
                ✅ [Response] \(endpoint) (\(statusCode))
                \(logBody)
                """)
            } else if let error = response.error {
                Logger.network.error("""
                ❌ [Error] \(endpoint) (\(statusCode))
                \(error.localizedDescription)
                """)
            }
        }
        #endif
        
        // 3. 디코딩 및 반환
        return try await request
            .serializingDecodable(T.self)
            .value
    }
    
    /// 공통 비동기 요청 메서드 (Concurrency + Logging) - 파라미터 없음
    /// 파라미터 없이 호출할 때 컴파일러가 P 타입을 추론할 수 없으므로 오버로딩 필요
    func request<T: Decodable>(_ endpoint: String,
                               method: HTTPMethod) async throws -> T {
        // P 타입을 Dummy(Void와 유사)로 지정하여 위 메서드 호출
        // Alamofire에서 nil 파라미터 전달 시 타입은 무시됨
        return try await request(endpoint, method: method, parameters: nil as String?, encoder: JSONParameterEncoder.default)
    }
}
