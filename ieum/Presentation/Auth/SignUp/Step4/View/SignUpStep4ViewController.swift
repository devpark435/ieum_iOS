import UIKit
import SnapKit
import Then
import Combine

class SignUpStep4ViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    private let viewModel = SignUpStep4ViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var diagnosisButtons: [String: IeumButton] = [:]
    
    // MARK: - UI Components
    
    private let stepBadgeChip = IeumChip(title: "3 / 7", type: .static).then {
        let text = "3 / 7"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: Colors.white, range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor, value: Colors.white.withAlphaComponent(0.5), range: NSRange(location: 1, length: 2))
        
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "진단명을 1개 이상\n선택해 주세요"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
        $0.setIeumText($0.text, style: UIFont.IeumFont.Heading.h1)
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    // 하단 선택완료 표시 및 다음 버튼
    private let bottomContainerView = UIView()
    
    private let countLabel = UILabel().then {
        $0.text = "0 개 선택완료"
        $0.font = .ieum(UIFont.IeumFont.Helper.characterCount)
        $0.textColor = Colors.Gray.g500 // 기본 회색, 선택 시 라임으로 변경 필요
        $0.textAlignment = .center
    }
    
    private let nextButton = IeumButton(title: "다음").then {
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .normal) // 활성화 전 색상 (이미지 참고: 연한 회색)
        // 활성화 시 색상은 로직에서 변경
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(didTapNext), for: .touchUpInside) // 타겟 추가
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground
        
        setupUI()
        setupLayout()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(stepBadgeChip)
        view.addSubview(titleLabel)
        view.addSubview(buttonStackView)
        
        viewModel.diagnosisList.forEach { name in
            let button = createDiagnosisButton(title: name)
            diagnosisButtons[name] = button
            buttonStackView.addArrangedSubview(button)
        }
        
        view.addSubview(bottomContainerView)
        bottomContainerView.addSubview(countLabel)
        bottomContainerView.addSubview(nextButton)
    }
    
    private func createDiagnosisButton(title: String) -> IeumButton {
        let button = IeumButton(title: title).then {
            $0.setStyle(backgroundColor: Colors.white, borderColor: Colors.transparent, titleColor: Colors.Slate.s900, for: .normal)
            $0.setStyle(backgroundColor: Colors.Slate.s900, borderColor: Colors.transparent, titleColor: Colors.white, for: .selected)
        }
        button.addTarget(self, action: #selector(didTapDiagnosis(_:)), for: .touchUpInside)
        return button
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
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 버튼 높이는 스택뷰 distribution으로 자동 조정되거나 개별 높이 지정
        buttonStackView.arrangedSubviews.forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(72)
            }
        }
        
        bottomContainerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(120) // 임의 높이
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
        
        countLabel.snp.makeConstraints {
            $0.bottom.equalTo(nextButton.snp.top).offset(-16)
            $0.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.$countText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countText in
                self?.updateCountLabel(text: countText)
            }
            .store(in: &cancellables)
        
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                guard let self = self else { return }
                self.nextButton.isEnabled = isEnabled
                if isEnabled {
                    self.nextButton.setStyle(backgroundColor: Colors.Lime.l400, titleColor: Colors.Gray.g950, for: .normal)
                } else {
                    self.nextButton.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .normal)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$selectedDiagnosis
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedDiagnosis in
                self?.updateButtonStates(selectedDiagnosis: selectedDiagnosis)
            }
            .store(in: &cancellables)
        
        viewModel.showStageSelection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] diagnosisName in
                self?.showStageSelection(for: diagnosisName)
            }
            .store(in: &cancellables)
        
        viewModel.navigateToNext
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.coordinator?.showStep5()
            }
            .store(in: &cancellables)
    }
    
    private func updateCountLabel(text: String) {
        let count = viewModel.selectedCount
        let attributedString = NSMutableAttributedString(string: text)
        let countRange = (text as NSString).range(of: "\(count)")
        attributedString.addAttribute(.foregroundColor, value: Colors.Lime.l500, range: countRange)
        countLabel.attributedText = attributedString
    }
    
    private func updateButtonStates(selectedDiagnosis: [String: String]) {
        for (title, stage) in selectedDiagnosis {
            if let button = diagnosisButtons[title] {
                button.isSelected = true
                if !stage.isEmpty {
                    button.setBadge(text: stage)
                } else {
                    button.setBadge(text: nil)
                }
            }
        }
        
        // 선택 해제된 버튼들 처리
        for (title, button) in diagnosisButtons {
            if !selectedDiagnosis.keys.contains(title) {
                button.isSelected = false
                button.setBadge(text: nil)
            }
        }
    }
    
    private func showStageSelection(for diagnosisName: String) {
        coordinator?.showStageSelection(cancerName: diagnosisName) { [weak self] stage in
            guard let self = self else { return }
            self.viewModel.selectDiagnosis(diagnosisName, stage: stage)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapDiagnosis(_ sender: IeumButton) {
        guard let title = sender.titleLabel?.text else { return }
        viewModel.didTapDiagnosis.send(title)
    }
    
    @objc private func didTapNext() {
        viewModel.didTapNext.send()
    }
}

