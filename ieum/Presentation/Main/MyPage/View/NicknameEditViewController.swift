import UIKit
import SnapKit
import Then
import Combine

final class NicknameEditViewController: UIViewController {
    
    // MARK: - Properties
    
    private let currentNickname: String
    private var onComplete: ((String) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.text = "닉네임 변경"
        $0.font = .ieum(UIFont.IeumFont.Heading.h1)
        $0.textColor = Colors.Gray.g950
        $0.numberOfLines = 0
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "ⓘ 닉네임변경은 한달에 한번 가능합니다."
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g600
    }
    
    private let nicknameInputView = IeumInputView(placeholder: "닉네임을 입력해주세요", maxCount: 20).then {
        $0.setBorderColors(defaultColor: Colors.Slate.s900, activeColor: Colors.Slate.s900)
    }
    
    private let saveButton = IeumButton(title: "변경하기", radius: 0).then {
        $0.setStyle(backgroundColor: Colors.Primary.lightGreen, titleColor: Colors.Gray.g950, for: .normal)
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
        $0.isEnabled = false
    }
    
    // MARK: - Initializer
    
    init(currentNickname: String, onComplete: @escaping (String) -> Void) {
        self.currentNickname = currentNickname
        self.onComplete = onComplete
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.ieumBackground
        
        setupUI()
        setupLayout()
        setupActions()
        
        nicknameInputView.textField.text = currentNickname
        updateSaveButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nicknameInputView.textField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = Colors.ieumBackground
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = Colors.Gray.g950
        
        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(nicknameInputView)
        view.addSubview(saveButton)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
        
        nicknameInputView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            $0.height.equalTo(56)
        }
    }
    
    private func setupActions() {
        nicknameInputView.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
    }
    
    private func updateSaveButtonState() {
        let text = nicknameInputView.textField.text ?? ""
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        saveButton.isEnabled = !trimmed.isEmpty && trimmed != currentNickname
    }
    
    // MARK: - Actions
    
    @objc private func textDidChange() {
        updateSaveButtonState()
    }
    
    @objc private func didTapSave() {
        guard let nickname = nicknameInputView.textField.text?.trimmingCharacters(in: .whitespaces),
              !nickname.isEmpty else { return }
        onComplete?(nickname)
    }
}
