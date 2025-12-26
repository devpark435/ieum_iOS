import UIKit
import SnapKit
import Then
import Combine

class SignUpStep3ViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SignUpCoordinator?
    private let viewModel = SignUpStep3ViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let stepBadgeChip = IeumChip(title: "3 / 7", type: .static).then {
        let text = "3 / 7"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: Colors.white, range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor, value: Colors.white.withAlphaComponent(0.5), range: NSRange(location: 1, length: 2))
        
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "사용하실 닉네임을\n입력해 주세요"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
        $0.setIeumText($0.text, style: UIFont.IeumFont.Heading.h1)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "ⓘ 닉네임변경은 한달에 한번 가능합니다."
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g600
    }
    
    private let nicknameInputView = IeumInputView(placeholder: "닉네임을 입력해주세요", maxCount: 20).then {
        $0.setBorderColors(defaultColor: Colors.Slate.s900, activeColor: Colors.Slate.s900)
    }
    
    private let nextButton = IeumButton(title: "다음", radius: 0).then { // 하단 고정 버튼은 보통 radius 0
        $0.setStyle(backgroundColor: Colors.Primary.lightGreen, titleColor: Colors.Gray.g950, for: .normal)
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
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
        // 네비게이션 바 보이기
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nicknameInputView.textField.becomeFirstResponder() // 진입 시 키보드 올림
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        // 뒤로가기 버튼 커스텀 (이미지가 있다면)
        // 네비게이션 바의 배경색을 투명하게 하거나 색상을 맞추는 설정 필요
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = Colors.ieumBackground // 배경색과 일치
        appearance.shadowColor = .clear // 하단 라인 제거
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Colors.Gray.g950 // 버튼 색상
        
        // Back Button 텍스트 제거
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
    }
    
    private func setupUI() {
        view.addSubview(stepBadgeChip)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(nicknameInputView)
        view.addSubview(nextButton)
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
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
        
        nicknameInputView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 키보드 위에 붙는 버튼 (Keyboard Layout Guide 활용 또는 하단 고정)
        // 여기서는 간단히 하단 고정 + 키보드 감지 로직 필요하지만, 우선 safeArea 하단에 배치
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top) // iOS 15+ 키보드 레이아웃 가이드
            $0.height.equalTo(56)
        }
    }
    
    private func setupActions() {
        nicknameInputView.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: &cancellables)
        
        viewModel.navigateToNext
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.coordinator?.showStep4()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func textDidChange() {
        let text = nicknameInputView.textField.text ?? ""
        viewModel.nicknameText.send(text)
    }
    
    @objc private func didTapNext() {
        viewModel.didTapNext.send()
    }
}
