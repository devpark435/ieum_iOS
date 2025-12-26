import Foundation
import Combine

final class SignUpStep6ViewModel: ObservableObject {
    // Inputs
    let didSelectCity = PassthroughSubject<Int, Never>()
    let didSelectDistrict = PassthroughSubject<Int, Never>()
    let didTapSkip = PassthroughSubject<Void, Never>()
    let didTapNext = PassthroughSubject<Void, Never>()
    
    // Outputs
    @Published private(set) var selectedCityIndex: Int? = 0
    @Published private(set) var selectedDistrictIndex: Int?
    @Published private(set) var isNextButtonEnabled = false
    
    // Navigation Events
    let navigateToNext = PassthroughSubject<Void, Never>()
    
    // Data
    let cities = [
        "서울특별시", "경기도", "부산광역시", "대구광역시",
        "인천광역시", "광주광역시", "대전광역시", "울산광역시",
        "세종특별자치시", "강원특별자치도", "충청북도", "충청남도",
        "전북특별자치도", "전라남도", "경상북도", "경상남도", "제주특별자치도"
    ]
    
    let districts: [String: [String]] = [
        "서울특별시": [
            "강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구",
            "노원구", "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구", "성동구",
            "성북구", "송파구", "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"
        ],
        "경기도": [
            "수원시", "성남시", "안양시", "안산시", "용인시", "고양시", "평택시", "과천시",
            "광명시", "광주시", "구리시", "군포시", "김포시", "남양주시", "동두천시", "부천시",
            "시흥시", "안성시", "양주시", "오산시", "의정부시", "이천시", "파주시", "하남시",
            "화성시", "여주시", "양평군", "가평군", "연천군", "포천시"
        ]
        // TODO: 나머지 지역 데이터 추가
    ]
    
    var currentDistricts: [String] {
        guard let index = selectedCityIndex else { return [] }
        return districts[cities[index]] ?? []
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindInputs()
    }
    
    private func bindInputs() {
        didSelectCity
            .sink { [weak self] index in
                self?.selectedCityIndex = index
                self?.selectedDistrictIndex = nil
                self?.isNextButtonEnabled = false
            }
            .store(in: &cancellables)
        
        didSelectDistrict
            .sink { [weak self] index in
                self?.selectedDistrictIndex = index
                self?.isNextButtonEnabled = true
            }
            .store(in: &cancellables)
        
        didTapSkip
            .sink { [weak self] in
                self?.navigateToNext.send()
            }
            .store(in: &cancellables)
        
        didTapNext
            .sink { [weak self] in
                self?.navigateToNext.send()
            }
            .store(in: &cancellables)
    }
}

