import Foundation

struct SurgeryHistoryItem {
    var date: Date?
    var description: String
}

struct ChemotherapyHistoryItem {
    var cycle: Int
    var startDate: Date?
    var endDate: Date?
    var isInProgress: Bool
}

struct RadiationHistoryItem {
    var startDate: Date?
    var endDate: Date?
    var isInProgress: Bool
}
