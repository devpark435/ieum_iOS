import UIKit
import SnapKit
import Then

class SignUpStep6ViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let stepBadgeChip = IeumChip(title: "5 / 7", type: .static).then {
        let text = "5 / 7"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: Colors.white, range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor, value: Colors.white.withAlphaComponent(0.5), range: NSRange(location: 1, length: 2))
        
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "거주하고 계신 지역을\n알려주세요"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
        $0.setIeumText($0.text, style: UIFont.IeumFont.Heading.h1)
    }
    
    // 지역 선택 컨테이너
    private let selectionContainerView = UIView().then {
        $0.backgroundColor = Colors.white
        // 상단 라인은 별도 뷰로 추가 (전체 border 제거)
    }
    
    private let topBorderView = UIView().then {
        $0.backgroundColor = Colors.Gray.g200
    }
    
    private let cityTableView = UITableView().then {
        $0.backgroundColor = Colors.white
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(RegionCell.self, forCellReuseIdentifier: RegionCell.identifier)
    }
    
    private let districtTableView = UITableView().then {
        $0.backgroundColor = Colors.white
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(RegionCell.self, forCellReuseIdentifier: RegionCell.identifier)
    }
    
    // 하단 그라데이션 뷰
    private let gradientView = UIView().then {
        $0.isUserInteractionEnabled = false // 터치 통과
    }
    
    // 하단 버튼 컨테이너
    private let bottomStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    private let skipButton = IeumButton(title: "건너뛰기").then {
        $0.setStyle(backgroundColor: Colors.Gray.g50, borderColor: Colors.Gray.g100, titleColor: Colors.Slate.s900, for: .normal)
    }
    
    private let nextButton = IeumButton(title: "다음").then {
        // 활성화: Lime400 배경, Lime200 테두리
        $0.setStyle(backgroundColor: Colors.Lime.l400, borderColor: Colors.Lime.l200, titleColor: Colors.Gray.g950, for: .normal)
        // 비활성화
        $0.setStyle(backgroundColor: Colors.Lime.l100, titleColor: Colors.Gray.g400, for: .disabled)
        $0.isEnabled = false
    }
    
    // MARK: - Data
    
    // TODO: 행정구역 데이터 API 연동 또는 로컬 데이터 고도화
    private let cities = [
        "서울특별시", "경기도", "부산광역시", "대구광역시",
        "인천광역시", "광주광역시", "대전광역시", "울산광역시",
        "세종특별자치시", "강원특별자치도", "충청북도", "충청남도",
        "전북특별자치도", "전라남도", "경상북도", "경상남도", "제주특별자치도"
    ]
    
    private let districts: [String: [String]] = [
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
        ],
        "부산광역시": [
            "강서구", "금정구", "기장군", "남구", "동구", "동래구", "부산진구", "북구",
            "사상구", "사하구", "서구", "수영구", "연제구", "영도구", "중구", "해운대구"
        ],
        "대구광역시": [
            "남구", "달서구", "동구", "북구", "서구", "수성구", "중구", "달성군", "군위군"
        ],
        "인천광역시": [
            "강화군", "계양구", "남동구", "동구", "미추홀구", "부평구", "서구", "연수구", "옹진군", "중구"
        ],
        "광주광역시": [
            "광산구", "남구", "동구", "북구", "서구"
        ],
        "대전광역시": [
            "대덕구", "동구", "서구", "유성구", "중구"
        ],
        "울산광역시": [
            "남구", "동구", "북구", "중구", "울주군"
        ],
        "세종특별자치시": [
            "세종시"
        ],
        "강원특별자치도": [
            "춘천시", "원주시", "강릉시", "동해시", "태백시", "속초시", "삼척시",
            "홍천군", "횡성군", "영월군", "평창군", "정선군", "철원군", "화천군",
            "양구군", "인제군", "고성군", "양양군"
        ],
        "충청북도": [
            "청주시", "충주시", "제천시", "보은군", "옥천군", "영동군", "증평군",
            "진천군", "괴산군", "음성군", "단양군"
        ],
        "충청남도": [
            "천안시", "공주시", "보령시", "아산시", "서산시", "논산시", "계룡시", "당진시",
            "금산군", "부여군", "서천군", "청양군", "홍성군", "예산군", "태안군"
        ],
        "전북특별자치도": [
            "전주시", "군산시", "익산시", "정읍시", "남원시", "김제시",
            "완주군", "진안군", "무주군", "장수군", "임실군", "순창군", "고창군", "부안군"
        ],
        "전라남도": [
            "목포시", "여수시", "순천시", "나주시", "광양시",
            "담양군", "곡성군", "구례군", "고흥군", "보성군", "화순군", "장흥군",
            "강진군", "해남군", "영암군", "무안군", "함평군", "영광군", "장성군", "완도군", "진도군", "신안군"
        ],
        "경상북도": [
            "포항시", "경주시", "김천시", "안동시", "구미시", "영주시", "영천시", "상주시", "문경시", "경산시",
            "군위군", "의성군", "청송군", "영양군", "영덕군", "청도군", "고령군", "성주군",
            "칠곡군", "예천군", "봉화군", "울진군", "울릉군"
        ],
        "경상남도": [
            "창원시", "진주시", "통영시", "사천시", "김해시", "밀양시", "거제시", "양산시",
            "의령군", "함안군", "창녕군", "고성군", "남해군", "하동군", "산청군", "함양군", "거창군", "합천군"
        ],
        "제주특별자치도": [
            "제주시", "서귀포시"
        ]
    ]
    
    private var selectedCityIndex: Int? = 0 // 기본 서울 선택
    private var selectedDistrictIndex: Int? = nil
    
    private var currentDistricts: [String] {
        guard let index = selectedCityIndex else { return [] }
        return districts[cities[index]] ?? []
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground
        
        setupUI()
        setupLayout()
        setupTableView()
        setupActions()
        
        // 초기 선택 상태 (서울)
        // 지연 실행을 통해 테이블뷰 로드 후 선택되도록 함
        DispatchQueue.main.async { [weak self] in
            self?.cityTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(stepBadgeChip)
        view.addSubview(titleLabel)
        
        view.addSubview(selectionContainerView)
        selectionContainerView.addSubview(topBorderView) // 상단 라인 추가
        selectionContainerView.addSubview(cityTableView)
        selectionContainerView.addSubview(districtTableView)
        
        // 그라데이션 뷰 추가 (테이블뷰 위에)
        selectionContainerView.addSubview(gradientView)
        
        view.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(skipButton)
        bottomStackView.addArrangedSubview(nextButton)
    }
    
    private func setupLayout() {
        stepBadgeChip.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(stepBadgeChip.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        selectionContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomStackView.snp.top).offset(-20)
        }
        
        topBorderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // 좌측(시/도) 35%, 우측(구/군) 65% 비율
        cityTableView.snp.makeConstraints {
            $0.top.equalTo(topBorderView.snp.bottom) // 상단 라인 아래부터
            $0.bottom.leading.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.35)
        }
        
        districtTableView.snp.makeConstraints {
            $0.top.equalTo(topBorderView.snp.bottom)
            $0.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(cityTableView.snp.trailing)
        }
        
        // 구분선 (Vertical Line)
        let separatorLine = UIView().then { $0.backgroundColor = Colors.Gray.g200 }
        selectionContainerView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(cityTableView.snp.trailing)
            $0.width.equalTo(1)
        }
        
        // 그라데이션 뷰 레이아웃 (하단 전체 영역)
        gradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(100) // 부드럽게 사라지는 효과
        }
        
        bottomStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
    }
    
    private func updateGradientLayer() {
        // 기존 레이어 제거 후 다시 생성 (리사이징 대응)
        gradientView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        // 투명 -> 흰색 (하단으로 갈수록 흰색)
        gradientLayer.colors = [
            Colors.white.withAlphaComponent(0.0).cgColor,
            Colors.white.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
        
        // 뷰 계층 순서 보장
        selectionContainerView.bringSubviewToFront(gradientView)
    }
    
    private func setupTableView() {
        cityTableView.delegate = self
        cityTableView.dataSource = self
        districtTableView.delegate = self
        districtTableView.dataSource = self
    }
    
    private func setupActions() {
        skipButton.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapSkip() {
        // TODO: 거주지역 선택 건너뛰기 처리 (nil 전송 등)
        navigateToNextStep()
    }
    
    @objc private func didTapNext() {
        // TODO: 선택된 지역 정보 저장
        navigateToNextStep()
    }
    
    private func navigateToNextStep() {
        let step7VC = SignUpStep7ViewController()
        navigationController?.pushViewController(step7VC, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SignUpStep6ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cityTableView {
            return cities.count
        } else {
            return currentDistricts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RegionCell.identifier, for: indexPath) as? RegionCell else {
            return UITableViewCell()
        }
        
        if tableView == cityTableView {
            cell.configure(text: cities[indexPath.row], type: .city)
        } else {
            let districts = currentDistricts
            if indexPath.row < districts.count {
                cell.configure(text: districts[indexPath.row], type: .district)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 뷰가 로드될 때 선택 상태 복원 (특히 리로드 시 중요)
        if tableView == cityTableView {
            if indexPath.row == selectedCityIndex {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        } else {
            if let selectedIndex = selectedDistrictIndex, indexPath.row == selectedIndex {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cityTableView {
            selectedCityIndex = indexPath.row
            selectedDistrictIndex = nil // 시/도 변경 시 구/군 초기화
            nextButton.isEnabled = false
            
            // 데이터 갱신
            districtTableView.reloadData()
            
            // 첫번째 항목으로 스크롤 이동
            if !currentDistricts.isEmpty {
                districtTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        } else {
            selectedDistrictIndex = indexPath.row
            nextButton.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56 // 셀 높이
    }
}

// MARK: - Cell

class RegionCell: UITableViewCell {
    static let identifier = "RegionCell"
    
    enum CellType {
        case city
        case district
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g600
        $0.textAlignment = .left
    }
    
    private var type: CellType = .city
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none // 기본 선택 스타일 제거 (배경색 직접 관리)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(10)
        }
    }
    
    func configure(text: String, type: CellType) {
        self.titleLabel.text = text
        self.type = type
        // 재사용 셀이므로 초기화 시 현재 선택 상태에 따라 UI 업데이트 필요
        // 하지만 willDisplay에서 selectRow를 호출하면 setSelected가 불리므로 여기선 기본값(미선택)으로 두거나
        // 명시적으로 업데이트 로직을 둠. setSelected 오버라이드 방식이 가장 안전.
    }
    
    // 테이블뷰가 선택 상태를 변경할 때 호출됨
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateAppearance(isSelected: selected)
    }
    
    private func updateAppearance(isSelected: Bool) {
        if isSelected {
            titleLabel.textColor = Colors.Gray.g950
            titleLabel.font = .ieum(UIFont.IeumFont.Btn.medium) // 선택 시 굵게
            
            if type == .city {
                contentView.backgroundColor = Colors.Slate.s300 // #CBD5E1
            } else {
                contentView.backgroundColor = Colors.Slate.s100 // #F1F5F9
            }
        } else {
            titleLabel.textColor = Colors.Gray.g600
            titleLabel.font = .ieum(UIFont.IeumFont.Text.bodyM)
            
            if type == .city {
                contentView.backgroundColor = Colors.Gray.g50 // 기본 배경 Gray50
            } else {
                contentView.backgroundColor = Colors.white
            }
        }
    }
}
