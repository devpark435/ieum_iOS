import Alamofire
import Foundation
import Combine

final class APIService {
    static let shared = APIService()
    let session: Session
    
    private init() {
        let interceptor = AuthInterceptor()
        let logger = APIRequestLogger()
        session = Session(interceptor: interceptor, eventMonitors: [logger])
    }
    
    var baseURL: String {
        return Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String ?? ""
    }
}
