import Foundation

// MARK: - Post Model

struct Post: Codable {
    let id: Int
    let userId: Int
    let userNickname: String
    let type: PostType
    let title: String
    let content: String
    let diagnosis: [Diagnosis]
    let mood: Int
    let unusualSymptoms: String?
    let medicationTaken: Bool
    let diet: Diet?
    let memo: String?
    let images: [ImageInfo]
    let likesCount: Int
    let commentsCount: Int
    let createdAt: Int64
    let updatedAt: Int64
    let isLiked: Bool
}

// MARK: - PostType

enum PostType: String, Codable {
    case wellness
    case treatment
    case daily
    case question
}

// MARK: - Diagnosis

enum Diagnosis: String, Codable {
    case rectalCancer = "rectal_cancer"
    case colonCancer = "colon_cancer"
    case breastCancer = "breast_cancer"
    case liverTransplant = "liver_transplant"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .rectalCancer:
            return "직장암"
        case .colonCancer:
            return "대장암"
        case .breastCancer:
            return "유방암"
        case .liverTransplant:
            return "간이식"
        case .other:
            return "기타"
        }
    }
}

// MARK: - Diet

struct Diet: Codable {
    let amountEaten: AmountEaten
    let mealContent: String
}

// MARK: - AmountEaten

enum AmountEaten: String, Codable {
    case wellEaten = "well_eaten"
    case normal = "normal"
    case little = "little"
    case none = "none"
    
    var displayName: String {
        switch self {
        case .wellEaten:
            return "잘 먹음"
        case .normal:
            return "보통"
        case .little:
            return "조금"
        case .none:
            return "안 먹음"
        }
    }
}

// MARK: - ImageInfo

struct ImageInfo: Codable {
    let url: String
    let filename: String
    let uploadedAt: Int64
}

