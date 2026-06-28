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
        let raw = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String ?? ""
        // endpoint가 "/"로 시작하므로 trailing slash 제거해 "//" 중복 방지
        return raw.replacingOccurrences(of: "/+$", with: "", options: .regularExpression)
    }
    
    /// 공통 비동기 요청 메서드 (Concurrency + Logging) - 파라미터 있음
    func request<T: Decodable, P: Encodable>(_ endpoint: String,
                                             method: HTTPMethod,
                                             parameters: P? = nil,
                                             encoder: ParameterEncoder = JSONParameterEncoder.default) async throws -> T {
        
        let fullURL = "\(baseURL)\(endpoint)"
        
        // 1. 요청 로그
        Logger.network.debug("🚀 [Request] \(method.rawValue) \(endpoint)")
        
        #if DEBUG
        if let parameters = parameters,
           let data = try? JSONEncoder().encode(parameters),
           let bodyString = String(data: data, encoding: .utf8) {
            Logger.network.debug("📦 [Request Body] \(bodyString)")
        }
        #endif
        
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
        return try await request(endpoint, method: method, parameters: nil as String?, encoder: JSONParameterEncoder.default)
    }
    
    /// 204 No Content 응답 처리용 메서드
    func requestNoContent(_ endpoint: String, method: HTTPMethod) async throws {
        let fullURL = "\(baseURL)\(endpoint)"
        
        Logger.network.debug("🚀 [Request] \(method.rawValue) \(endpoint)")
        
        let request = session.request(fullURL, method: method)
            .validate(statusCode: [200, 204])
        
        #if DEBUG
        request.responseData { response in
            let statusCode = response.response?.statusCode ?? 0
            Logger.network.debug("✅ [Response] \(endpoint) (\(statusCode)) - No Content")
        }
        #endif
        
        try await request.serializingData().value
    }
    
    /// Multipart Upload 메서드 (이미지 + JSON 데이터) - POST 기본
    func upload<T: Decodable>(_ endpoint: String,
                              multipartFormData: @escaping (MultipartFormData) -> Void) async throws -> T {
        return try await upload(endpoint, method: .post, multipartFormData: multipartFormData)
    }
    
    /// Multipart Upload 메서드 (이미지 + JSON 데이터) - 메서드 지정 가능
    func upload<T: Decodable>(_ endpoint: String,
                              method: HTTPMethod,
                              multipartFormData: @escaping (MultipartFormData) -> Void) async throws -> T {
        let fullURL = "\(baseURL)\(endpoint)"
        
        Logger.network.debug("🚀 [Upload] \(method.rawValue) \(endpoint)")
        
        var urlRequest = try URLRequest(url: fullURL, method: method)
        // Content-Type은 Alamofire가 boundary와 함께 자동으로 설정함
        
        let request = session.upload(multipartFormData: multipartFormData, with: urlRequest)
            .validate()
        
        #if DEBUG
        request.responseData { response in
            let statusCode = response.response?.statusCode ?? 0
            
            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                var logBody = jsonString
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                   let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    logBody = prettyString
                }
                
                Logger.network.debug("""
                ✅ [Upload Response] \(endpoint) (\(statusCode))
                \(logBody)
                """)
            } else if let error = response.error {
                Logger.network.error("""
                ❌ [Upload Error] \(endpoint) (\(statusCode))
                \(error.localizedDescription)
                """)
            }
        }
        #endif
        
        return try await request
            .serializingDecodable(T.self)
            .value
    }
}
