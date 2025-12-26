import UIKit
import SnapKit
import Then
import Combine

class SignUpStep7ViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    private let viewModel = SignUpStep7ViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let stepBadgeChip = IeumChip(title: "6 / 7", type: .static).then {
        let text = "6 / 7" // Step 7인데 이미지상 4/7로 되어있음. Step 7이 맞으므로 6/7로 표기하거나 기획 확인 필요. (일단 순서상 7번째이므로 6/7 or 7/7)
        // User Query: "4/7" (이미지) -> 하지만 Step 6 다음이니 7단계가 맞음.
        // 여기서는 흐름상 마지막 입력 단계이므로 6/7 또는 7/7로 설정. (완료 화면 제외하면 총 6단계?)
        // 일단 6/7로 설정하겠습니다.
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: Colors.white, range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor, value: Colors.white.withAlphaComponent(0.5), range: NSRange(location: 1, length: 4)) // " / 7"
        
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "요즘 가장 관심이 가는\n주제가 무엇인가요?"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
        $0.setIeumText($0.text, style: UIFont.IeumFont.Heading.h1)
    }
    
    private let interestInputView = IeumInputView(placeholder: "자유롭게 입력해 주세요", maxCount: 50).then {
        $0.setBorderColors(defaultColor: Colors.Slate.s900, activeColor: Colors.Slate.s900)
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
        $0.setStyle(backgroundColor: Colors.Lime.l400, borderColor: Colors.Lime.l200, titleColor: Colors.Gray.g950, for: .normal)
        $0.setStyle(backgroundColor: Colors.Lime.l100, titleColor: Colors.Gray.g400, for: .disabled)
        $0.isEnabled = false
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground
        
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
        view.addSubview(interestInputView)
        
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
        
        interestInputView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(56)
        }
    }
    
    private func setupActions() {
        interestInputView.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        skipButton.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: &cancellables)
        
        viewModel.navigateToComplete
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.coordinator?.showComplete()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func textDidChange() {
        let text = interestInputView.textField.text ?? ""
        viewModel.interestText.send(text)
    }
    
    @objc private func didTapSkip() {
        viewModel.didTapSkip.send()
    }
    
    @objc private func didTapNext() {
        viewModel.didTapNext.send()
    }
}

