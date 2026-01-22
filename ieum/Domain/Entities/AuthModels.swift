import Foundation

enum SocialLoginType: String, Codable, Sendable {
    case kakao
    case apple
}

struct AppLoginRequest: Codable, Sendable {
    let accessToken: String
}

struct AppLoginResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String
    let user: AppOAuthUser
}

struct AppOAuthUser: Codable, Sendable {
    let oauthId: String
    let provider: String
    let email: String?
    let name: String?
    let profileImage: String?
    let isRegistered: Bool
}

struct AppTokenRefreshRequest: Codable, Sendable {
    let refreshToken: String
}

struct AppTokenResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String
}
