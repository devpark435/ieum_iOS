import Foundation

struct UserProfile: Codable {
    let id: Int
    let oauthProvider: String
    let email: String
    let userType: String // "patient", "caregiver"
    let sex: String // "male", "female"
    let nickname: String
    let diagnoses: [UserDiagnosis]
    let surgery: [Surgery]?
    let chemotherapy: [Chemotherapy]?
    let radiationTherapy: [RadiationTherapy]?
    let ageGroup: String?
    let residenceArea: String?
    let hospitalArea: String?
    
    // Visibility flags
    let sexVisible: Bool
    let diagnosesVisible: Bool
    let surgeryVisible: Bool
    let chemotherapyVisible: Bool
    let radiationTherapyVisible: Bool
    let ageGroupVisible: Bool
    let residenceAreaVisible: Bool
    let hospitalAreaVisible: Bool
    
    let registeredAt: Int64
    let updatedAt: Int64
}

struct UserDiagnosis: Codable {
    let diagnosis: String // "rectal_cancer", etc.
    let cancerStage: Int?
    
    var diagnosisDisplayName: String {
        switch diagnosis {
        case "rectal_cancer": return "직장암"
        case "colon_cancer": return "대장암"
        case "breast_cancer": return "유방암"
        case "liver_transplant": return "간이식"
        case "others": return "기타"
        default: return diagnosis
        }
    }
}

struct Surgery: Codable {
    let date: String
    let description: String
}

struct Chemotherapy: Codable {
    let startDate: String
    let endDate: String?
    let cycle: Int
}

struct RadiationTherapy: Codable {
    let startDate: String
    let endDate: String?
}
