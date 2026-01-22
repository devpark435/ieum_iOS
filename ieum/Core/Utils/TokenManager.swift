import Foundation
import Security

final class TokenManager {
    static let shared = TokenManager()
    
    private let service = "com.ieum.app"
    private let accountAccess = "accessToken"
    private let accountRefresh = "refreshToken"
    
    private init() {}
    
    func save(accessToken: String, refreshToken: String) {
        save(key: accountAccess, value: accessToken)
        save(key: accountRefresh, value: refreshToken)
    }
    
    func getAccessToken() -> String? {
        return read(key: accountAccess)
    }
    
    func getRefreshToken() -> String? {
        return read(key: accountRefresh)
    }
    
    func clearTokens() {
        delete(key: accountAccess)
        delete(key: accountRefresh)
    }
    
    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // 기존 데이터 삭제 후 저장
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
