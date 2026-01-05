import UIKit

enum MedicationStatus: String {
    case taken = "완료"
    case notTaken = "미완료"
    
    var apiValue: Bool {
        return self == .taken
    }
}

enum MealStatus: String {
    case good = "잘먹음"
    case little = "소량"
    case bad = "못먹음"
    
    var iconName: String {
        switch self {
        case .good: return "face.smiling" // 시스템 이미지 (임시)
        case .little: return "face.dashed"
        case .bad: return "face.frown"
        }
    }
    
    var apiValue: String {
        switch self {
        case .good: return "well_eaten"
        case .little: return "small_amount"
        case .bad: return "barely_eaten"
        }
    }
}

struct TreatmentRecordModel {
    var mood: Int? // 1~5
    var symptom: String?
    var medication: MedicationStatus?
    var meal: MealStatus?
    var mealDescription: String?
    var memo: String?
    var photos: [UIImage] = []
    var isPublic: Bool = false
    
    var isValid: Bool {
        // 필수값: 기분(mood), 복약(medication), 공유여부(isPublic - 기본값 있음)
        return mood != nil && medication != nil
    }
    
    // API 요청 데이터 생성 메서드
    func toCreateRequestData() -> CreateWellnessPostData? {
        guard let mood = mood,
              let medication = medication else { return nil }
        
        var dietData: DietData?
        if let meal = meal {
            dietData = DietData(amountEaten: meal.apiValue, mealContent: mealDescription)
        }
        
        return CreateWellnessPostData(
            diagnosis: nil, // TODO: 필요 시 사용자 진단명 목록 주입
            mood: mood,
            unusualSymptoms: symptom,
            medicationTaken: medication.apiValue,
            diet: dietData,
            memo: memo,
            shared: isPublic
        )
    }
}
