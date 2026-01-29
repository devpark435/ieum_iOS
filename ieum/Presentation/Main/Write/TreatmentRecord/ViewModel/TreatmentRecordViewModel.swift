import Foundation
import Combine
import UIKit
import Kingfisher

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
    
    // 수정 모드
    private let isEditMode: Bool
    private let postId: Int?
    
    init(post: Post? = nil, feedRepository: FeedRepository = FeedRepositoryImpl()) {
        self.feedRepository = feedRepository
        self.isEditMode = post != nil
        self.postId = post?.id
        
        if let post = post {
            loadPostData(post)
        }
        
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
        
        if isEditMode {
            updateRecord()
        } else {
            createRecord()
        }
    }
    
    private func createRecord() {
        guard let requestData = recordModel.toCreateRequestData() else { return }
        
        isLoading = true
        
        // 이미지 변환
        let imageDatas = recordModel.photos.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        // API 호출
        feedRepository.createWellnessPost(data: requestData, images: imageDatas.isEmpty ? nil : imageDatas)
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
    
    private func updateRecord() {
        guard let postId = postId else { return }
        
        isLoading = true
        
        // UpdateWellnessPostData 생성 (변경된 필드만 포함)
        let updateData = UpdateWellnessPostData(
            diagnosis: nil, // 수정 시 진단명 변경 불가 (명세서 참고)
            mood: recordModel.mood,
            unusualSymptoms: recordModel.symptom,
            medicationTaken: recordModel.medication?.apiValue,
            diet: recordModel.meal.map { meal in
                let amountEaten: AmountEaten
                switch meal {
                case .good: amountEaten = .wellEaten
                case .little: amountEaten = .smallAmount
                case .bad: amountEaten = .barelyEaten
                }
                return Diet(amountEaten: amountEaten, mealContent: recordModel.mealDescription)
            },
            memo: recordModel.memo,
            shared: recordModel.isPublic
        )
        
        // 이미지 변환 (있는 경우만)
        let imageDatas = recordModel.photos.isEmpty ? nil : recordModel.photos.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        // API 호출
        feedRepository.updateWellnessPost(id: postId, data: updateData, images: imageDatas)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    print("Update Error: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.postSuccess.send()
                Toast.show(message: "치료 기록 수정을 완료했습니다")
                NotificationCenter.default.post(name: NSNotification.Name("PostCreated"), object: nil)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Post Data
    
    private func loadPostData(_ post: Post) {
        guard post.type == .wellness else { return }
        
        var model = TreatmentRecordModel()
        
        // Mood
        if let mood = post.mood {
            model.mood = mood
        }
        
        // Symptom
        model.symptom = post.unusualSymptoms
        
        // Medication
        if let medicationTaken = post.medicationTaken {
            model.medication = medicationTaken ? .taken : .notTaken
        }
        
        // Meal
        if let diet = post.diet {
            let mealStatus: MealStatus
            switch diet.amountEaten {
            case .wellEaten: mealStatus = .good
            case .smallAmount: mealStatus = .little
            case .barelyEaten: mealStatus = .bad
            }
            model.meal = mealStatus
            model.mealDescription = diet.mealContent
        }
        
        // Memo
        model.memo = post.memo
        
        // Public Status
        model.isPublic = post.shared ?? false
        
        recordModel = model
        
        // Load images from URLs
        if let images = post.images, !images.isEmpty {
            loadImages(from: images)
        }
    }
    
    private func loadImages(from imageInfos: [ImageInfo]) {
        let group = DispatchGroup()
        var loadedImages: [UIImage] = []
        
        for imageInfo in imageInfos {
            guard let url = URL(string: imageInfo.url) else { continue }
            
            group.enter()
            KingfisherManager.shared.retrieveImage(with: url) { result in
                defer { group.leave() }
                
                switch result {
                case .success(let value):
                    loadedImages.append(value.image)
                case .failure(let error):
                    print("Failed to load image: \(error)")
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            var updatedModel = self.recordModel
            updatedModel.photos = loadedImages
            self.recordModel = updatedModel
        }
    }
}
