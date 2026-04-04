import Foundation
import Combine
import OSLog

final class MyPageViewModel: ObservableObject {
    
    // MARK: - Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let didTapEditProfile = PassthroughSubject<Void, Never>()
    let didTapEditNickname = PassthroughSubject<Void, Never>()
    let didTapInfoSection = PassthroughSubject<InfoSectionType, Never>()
    
    // MARK: - Outputs
    @Published private(set) var userProfile: UserProfile?
    @Published private(set) var isLoading = false
    
    private let authRepository: AuthRepository
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.authRepository = authRepository
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
        
        authRepository.getProfile()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        Logger.network.error("프로필 조회 실패: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] profile in
                    self?.userProfile = profile
                    self?.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
    
    func updateProfile(_ request: UpdateProfileRequest) -> AnyPublisher<UserProfile, Error> {
        isLoading = true
        
        return authRepository.updateProfile(request)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] profile in
                    self?.userProfile = profile
                    self?.isLoading = false
                },
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        Logger.network.error("프로필 수정 실패: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func createUpdateRequest(
        from profile: UserProfile,
        updatingNickname: String? = nil,
        updatingDiagnoses: [DiagnosisRequest]? = nil,
        updatingAgeGroup: String? = nil,
        updatingResidenceArea: String? = nil,
        updatingHospitalArea: String? = nil,
        updatingSurgery: [SurgeryRequest]? = nil,
        updatingChemotherapy: [ChemotherapyRequest]? = nil,
        updatingRadiationTherapy: [RadiationTherapyRequest]? = nil
    ) -> UpdateProfileRequest {
        let diagnoses: [DiagnosisRequest]? = updatingDiagnoses ?? {
            guard !profile.diagnoses.isEmpty else { return nil }
            return profile.diagnoses.compactMap { userDiagnosis -> DiagnosisRequest? in
                if userDiagnosis.diagnosis == "breast_cancer" {
                    return nil
                }
                
                var diagnosisType: DiagnosisType
                switch userDiagnosis.diagnosis {
                case "rectal_cancer":
                    diagnosisType = .rectalCancer
                case "colon_cancer":
                    diagnosisType = .colonCancer
                case "liver_transplant":
                    diagnosisType = .liverTransplant
                default:
                    diagnosisType = .others
                }
                
                return DiagnosisRequest(diagnosis: diagnosisType, cancerStage: userDiagnosis.cancerStage)
            }
        }()
        
        let surgery: [SurgeryRequest]? = updatingSurgery ?? {
            guard let surgeries = profile.surgery, !surgeries.isEmpty else { return nil }
            return surgeries.map { SurgeryRequest(date: $0.date, description: $0.description) }
        }()
        
        let chemotherapy: [ChemotherapyRequest]? = updatingChemotherapy ?? {
            guard let chemos = profile.chemotherapy, !chemos.isEmpty else { return nil }
            return chemos.map { ChemotherapyRequest(startDate: $0.startDate, endDate: $0.endDate, cycle: $0.cycle) }
        }()
        
        let radiationTherapy: [RadiationTherapyRequest]? = updatingRadiationTherapy ?? {
            guard let radiations = profile.radiationTherapy, !radiations.isEmpty else { return nil }
            return radiations.map { RadiationTherapyRequest(startDate: $0.startDate, endDate: $0.endDate) }
        }()
        
        return UpdateProfileRequest(
            nickname: updatingNickname,
            diagnoses: diagnoses,
            surgery: surgery,
            chemotherapy: chemotherapy,
            radiationTherapy: radiationTherapy,
            ageGroup: updatingAgeGroup ?? profile.ageGroup,
            residenceArea: updatingResidenceArea ?? profile.residenceArea,
            hospitalArea: updatingHospitalArea ?? profile.hospitalArea,
            sexVisible: profile.sexVisible,
            diagnosesVisible: profile.diagnosesVisible,
            surgeryVisible: profile.surgeryVisible,
            chemotherapyVisible: profile.chemotherapyVisible,
            radiationTherapyVisible: profile.radiationTherapyVisible,
            ageGroupVisible: profile.ageGroupVisible,
            residenceAreaVisible: profile.residenceAreaVisible,
            hospitalAreaVisible: profile.hospitalAreaVisible
        )
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
