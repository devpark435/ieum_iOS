import UIKit
import SnapKit
import Then
import Combine

class SignUpStep6ViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    private let viewModel = SignUpStep6ViewModel()
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private var cities: [String] {
        return viewModel.cities
    }
    
    private var districts: [String: [String]] {
        return viewModel.districts
    }
    
    private var currentDistricts: [String] {
        return viewModel.currentDistricts
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground
        
        setupUI()
        setupLayout()
        setupTableView()
        setupActions()
        bindViewModel()
        
        // 초기 선택 상태 (서울)
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
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.$selectedCityIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let self = self, let index = index else { return }
                self.cityTableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
                self.districtTableView.reloadData()
                if !self.currentDistricts.isEmpty {
                    self.districtTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$selectedDistrictIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let self = self, let index = index else { return }
                self.districtTableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
            }
            .store(in: &cancellables)
        
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: &cancellables)
        
        viewModel.navigateToNext
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.coordinator?.showStep7()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func didTapSkip() {
        viewModel.didTapSkip.send()
    }
    
    @objc private func didTapNext() {
        viewModel.didTapNext.send()
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
            if let selectedIndex = viewModel.selectedCityIndex, indexPath.row == selectedIndex {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        } else {
            if let selectedIndex = viewModel.selectedDistrictIndex, indexPath.row == selectedIndex {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cityTableView {
            viewModel.didSelectCity.send(indexPath.row)
        } else {
            viewModel.didSelectDistrict.send(indexPath.row)
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
