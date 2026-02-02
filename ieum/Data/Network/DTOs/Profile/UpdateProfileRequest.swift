import Foundation

struct UpdateProfileRequest: Codable, Sendable {
    let diagnoses: [DiagnosisRequest]?
    let surgery: [SurgeryRequest]?
    let chemotherapy: [ChemotherapyRequest]?
    let radiationTherapy: [RadiationTherapyRequest]?
    let ageGroup: String?
    let residenceArea: String?
    let hospitalArea: String?
    let sexVisible: Bool?
    let diagnosesVisible: Bool?
    let surgeryVisible: Bool?
    let chemotherapyVisible: Bool?
    let radiationTherapyVisible: Bool?
    let ageGroupVisible: Bool?
    let residenceAreaVisible: Bool?
    let hospitalAreaVisible: Bool?
}

struct SurgeryRequest: Codable, Sendable {
    let date: String
    let description: String
}

struct ChemotherapyRequest: Codable, Sendable {
    let startDate: String
    let endDate: String?
    let cycle: Int
}

struct RadiationTherapyRequest: Codable, Sendable {
    let startDate: String
    let endDate: String?
}
