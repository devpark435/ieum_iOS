import Foundation

// MARK: - Post Model

struct Post: Codable, Sendable {
    let id: Int
    let userId: Int
    let userNickname: String
    let type: PostType
    
    // Daily
    let title: String?
    let content: String?
    
    // Wellness
    let diagnosis: [String]?
    let mood: Int?
    let unusualSymptoms: String?
    let medicationTaken: Bool?
    let diet: Diet?
    let memo: String?
    
    // Common
    let images: [ImageInfo]?
    let likesCount: Int
    let isLiked: Bool
    let createdAt: Int
    let updatedAt: Int
}

// MARK: - PostType

enum PostType: String, Codable, Sendable {
    case wellness
    case daily
    case all // 조회 필터용
}

// MARK: - Diagnosis

enum Diagnosis: String, Codable, Sendable {
    case rectalCancer = "rectal_cancer"
    case colonCancer = "colon_cancer"
    case liverTransplant = "liver_transplant"
    case others = "others"
    
    var displayName: String {
        switch self {
        case .rectalCancer:
            return "직장암"
        case .colonCancer:
            return "대장암"
        case .liverTransplant:
            return "간이식"
        case .others:
            return "기타"
        }
    }
}

// MARK: - Diet

struct Diet: Codable, Sendable {
    let amountEaten: AmountEaten
    let mealContent: String?
}

// MARK: - AmountEaten

enum AmountEaten: String, Codable, Sendable {
    case wellEaten = "well_eaten"
    case smallAmount = "small_amount"
    case barelyEaten = "barely_eaten"
    
    var displayName: String {
        switch self {
        case .wellEaten:
            return "잘 먹음"
        case .smallAmount:
            return "소량"
        case .barelyEaten:
            return "못 먹음"
        }
    }
}

// MARK: - ImageInfo

struct ImageInfo: Codable, Sendable {
    let url: String
    let filename: String
    let uploadedAt: Int
}
