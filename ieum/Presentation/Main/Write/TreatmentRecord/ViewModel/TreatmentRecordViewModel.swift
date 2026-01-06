import Foundation
import Combine
import UIKit

final class TreatmentRecordViewModel: ObservableObject {
    // Inputs
    let didTapClose = PassthroughSubject<Void, Never>()
    let didTapPost = PassthroughSubject<Void, Never>()
    let postSuccess = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published var recordModel = TreatmentRecordModel()
    @Published private(set) var isPostButtonEnabled = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        $recordModel
            .map { model in
                // 게시하기 버튼 활성화 조건: 예시로 일단 true, 실제 조건에 따라 수정 가능
                // 예: 기분이 선택되었거나 내용이 하나라도 있거나 등
                return true
            }
            .assign(to: &$isPostButtonEnabled)
            
        didTapPost
            .sink { [weak self] in
                self?.postRecord()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Update Methods
    
    func updateMood(_ mood: Int) {
        recordModel.mood = mood
    }
    
    func updateSymptom(_ text: String?) {
        recordModel.symptom = text
    }
    
    func updateMedication(_ status: MedicationStatus) {
        recordModel.medication = status
    }
    
    func updateMeal(status: MealStatus, description: String?) {
        recordModel.meal = status
        recordModel.mealDescription = description
    }
    
    func updateMemo(_ text: String?) {
        recordModel.memo = text
    }
    
    func updatePhotos(_ photos: [UIImage]) {
        recordModel.photos = photos
    }
    
    func removePhoto(at index: Int) {
        guard index < recordModel.photos.count else { return }
        var photos = recordModel.photos
        photos.remove(at: index)
        recordModel.photos = photos
    }
    
    func updatePublicStatus(_ isPublic: Bool) {
        recordModel.isPublic = isPublic
    }
    
    private func postRecord() {
        // TODO: API 호출 로직 구현
        print("Post Record: \(recordModel)")
        
        // Mock Success after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.postSuccess.send()
        }
    }
}
