import Foundation
import Combine

final class MyPageViewModel: ObservableObject {
    
    // MARK: - Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didTapEditProfile = PassthroughSubject<Void, Never>()
    let didTapInfoSection = PassthroughSubject<InfoSectionType, Never>()
    
    // MARK: - Outputs
    @Published private(set) var userProfile: UserProfile?
    @Published private(set) var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        viewDidLoad
            .sink { [weak self] in
                self?.fetchUserProfile()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Logic
    
    private func fetchUserProfile() {
        isLoading = true
        
        // Mock Data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let mockProfile = UserProfile(
                id: 1,
                oauthProvider: "kakao",
                email: "user@example.com",
                userType: "patient",
                sex: "male",
                nickname: "user_me",
                diagnoses: [
                    UserDiagnosis(diagnosis: "rectal_cancer", cancerStage: 4),
                    UserDiagnosis(diagnosis: "colon_cancer", cancerStage: 4)
                ],
                surgery: [],
                chemotherapy: [],
                radiationTherapy: [],
                ageGroup: "30s",
                residenceArea: "서울특별시 강남구",
                hospitalArea: "서울특별시 강남구",
                sexVisible: false,
                diagnosesVisible: false,
                surgeryVisible: false,
                chemotherapyVisible: false,
                radiationTherapyVisible: false,
                ageGroupVisible: false,
                residenceAreaVisible: false,
                hospitalAreaVisible: false,
                registeredAt: 1754972400,
                updatedAt: 1754972400
            )
            
            self?.userProfile = mockProfile
            self?.isLoading = false
        }
    }
}

enum InfoSectionType {
    case diagnosis
    case surgery
    case chemotherapy
    case radiation
    case ageGroup
    case residence
}
