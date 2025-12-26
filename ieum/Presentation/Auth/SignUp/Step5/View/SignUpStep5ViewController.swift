import UIKit
import SnapKit
import Then
import Combine

class SignUpStep5ViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    private let viewModel = SignUpStep5ViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let stepBadgeChip = IeumChip(title: "4 / 7", type: .static).then {
        let text = "4 / 7"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: Colors.white, range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor, value: Colors.white.withAlphaComponent(0.5), range: NSRange(location: 1, length: 2))
        
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "연령대가\n어떻게 되시나요?"
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
        // 이미지상 활성화된 상태의 색상이 연두색(Lime) 계열
        $0.setStyle(backgroundColor: Colors.Lime.l400, titleColor: Colors.Gray.g950, for: .normal)
        $0.setStyle(backgroundColor: Colors.Lime.l100, titleColor: Colors.Gray.g400, for: .disabled)
        $0.isEnabled = false // 초기 비활성화
    }
    
    // MARK: - Data
    
    private var buttons: [IeumButton] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground // FBFDF4
        
        setupUI()
        setupLayout()
        setupActions()
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
        
        viewModel.ageGroups.forEach { title in
            let button = IeumButton(title: title).then {
                $0.setStyle(backgroundColor: Colors.white, borderColor: Colors.transparent, titleColor: Colors.Slate.s900, for: .normal)
                $0.setStyle(backgroundColor: Colors.Slate.s900, borderColor: Colors.transparent, titleColor: Colors.white, for: .selected)
            }
            button.addTarget(self, action: #selector(didTapAgeGroup(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
            buttons.append(button)
        }
        
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
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 버튼 높이는 스택뷰 distribution으로 자동 조정되거나 개별 높이 지정
        buttons.forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(72)
            }
        }
        
        bottomStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56) // 하단 버튼 높이
        }
    }
    
    private func setupActions() {
        skipButton.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.$selectedAgeGroup
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedAgeGroup in
                guard let self = self, let selectedAgeGroup = selectedAgeGroup else { return }
                self.buttons.forEach { button in
                    button.isSelected = (button.title(for: .normal) == selectedAgeGroup)
                }
                self.nextButton.isEnabled = true
            }
            .store(in: &cancellables)
        
        viewModel.navigateToNext
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.coordinator?.showStep6()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func didTapAgeGroup(_ sender: IeumButton) {
        guard let title = sender.title(for: .normal) else { return }
        viewModel.didSelectAgeGroup.send(title)
    }
    
    @objc private func didTapSkip() {
        viewModel.didTapSkip.send()
    }
    
    @objc private func didTapNext() {
        viewModel.didTapNext.send()
    }
}

