import Alamofire
import Foundation

final class APIRequestLogger: EventMonitor {
    let queue = DispatchQueue(label: "com.ieum.networklogger")

    // 요청이 시작될 때 호출
    func requestDidResume(_ request: Request) {
        print("🚀 [Request] --------------------------")
        print("URL: \(request.request?.url?.absoluteString ?? "nil")")
        print("Method: \(request.request?.httpMethod ?? "nil")")
        print("Headers: \(request.request?.allHTTPHeaderFields ?? [:])")
        if let body = request.request?.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("---------------------------------------")
    }

    // 응답이 왔을 때 호출 (성공/실패 무관)
    func request(_ request: Request, didParseResponse response: DataResponse<Any?, AFError>) {
        print("✅ [Response] -------------------------")
        print("URL: \(request.request?.url?.absoluteString ?? "nil")")
        print("Status Code: \(response.response?.statusCode ?? 0)")
        
        if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
            // JSON 포맷팅 시도 (옵션)
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("Data: \(prettyString)")
            } else {
                print("Data: \(jsonString)")
            }
        }
        
        if let error = response.error {
            print("⚠️ Error: \(error)")
        }
        print("---------------------------------------")
    }
}
