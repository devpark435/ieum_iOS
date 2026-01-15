import Foundation

class SignUpDataManager {
    static let shared = SignUpDataManager()
    
    var userType: String?
    var sex: String?
    var nickname: String?
    var diagnoses: [DiagnosisRequest] = []
    var ageGroup: String?
    var residenceArea: String?
    var hospitalArea: String?
    
    private init() {}
    
    func reset() {
        userType = nil
        sex = nil
        nickname = nil
        diagnoses = []
        ageGroup = nil
        residenceArea = nil
        hospitalArea = nil
    }
    
    func toRequest() -> UserRegistrationRequest? {
        guard let userType = userType,
              let sex = sex,
              let nickname = nickname,
              !diagnoses.isEmpty else {
            return nil
        }
        
        return UserRegistrationRequest(
            userType: userType,
            sex: sex,
            nickname: nickname,
            diagnoses: diagnoses,
            ageGroup: ageGroup,
            residenceArea: residenceArea,
            hospitalArea: hospitalArea
        )
    }
}
