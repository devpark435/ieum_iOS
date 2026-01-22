import Foundation

struct UserRegistrationRequest: Codable, Sendable {
    let userType: String
    let sex: String
    let nickname: String
    let diagnoses: [DiagnosisRequest]
    let ageGroup: String?
    let residenceArea: String?
    let hospitalArea: String?
}

struct DiagnosisRequest: Codable, Sendable {
    let diagnosis: DiagnosisType
    let cancerStage: Int? // 암인 경우 필수
}

struct UserRegistrationResponse: Codable, Sendable {
    let id: Int
    let oauthProvider: String
    let email: String?
    let userType: String
    let nickname: String
    let registeredAt: Int // Timestamp
}

enum DiagnosisType: String, Codable, Sendable {
    case rectalCancer = "rectal_cancer"
    case colonCancer = "colon_cancer"
    case liverTransplant = "liver_transplant"
    case others = "others"
    
    var title: String {
        switch self {
        case .rectalCancer: return "직장암"
        case .colonCancer: return "대장암"
        case .liverTransplant: return "간이식"
        case .others: return "기타"
        }
    }
}

enum UserType: String, Codable, CaseIterable, Sendable {
    case patient = "patient"
    case caregiver = "caregiver"
    
    var title: String {
        switch self {
        case .patient: return "환자"
        case .caregiver: return "보호자"
        }
    }
}

enum Gender: String, Codable, CaseIterable, Sendable {
    case male = "male"
    case female = "female"
    
    var title: String {
        switch self {
        case .male: return "남성"
        case .female: return "여성"
        }
    }
}

enum AgeGroup: String, Codable, CaseIterable, Sendable {
    case under30s = "under30s"
    case forties = "40s"
    case fifties = "50s"
    case sixties = "60s"
    case over70s = "over70s"
    
    var title: String {
        switch self {
        case .under30s: return "30대 이하"
        case .forties: return "40대"
        case .fifties: return "50대"
        case .sixties: return "60대"
        case .over70s: return "70대 이상"
        }
    }
}
