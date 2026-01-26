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
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let feedRepository: FeedRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(feedRepository: FeedRepository = FeedRepositoryImpl()) {
        self.feedRepository = feedRepository
        bindInputs()
    }
    
    private func bindInputs() {
        $recordModel
            .map { model in
                // 게시하기 버튼 활성화 조건: 기분(mood)과 복약(medication) 필수
                return model.mood != nil && model.medication != nil
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
        var newModel = recordModel
        newModel.meal = status
        newModel.mealDescription = description
        recordModel = newModel
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
        guard !isLoading else { return }
        guard let requestData = recordModel.toCreateRequestData() else { return }
        
        isLoading = true
        
        // 이미지 변환
        let imageDatas = recordModel.photos.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        // API 호출
        feedRepository.createWellnessPost(data: requestData, images: imageDatas)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    print("Upload Error: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.postSuccess.send()
                Toast.show(message: "치료 기록 작성을 완료했습니다")
                NotificationCenter.default.post(name: NSNotification.Name("PostCreated"), object: nil)
            }
            .store(in: &cancellables)
    }
}
