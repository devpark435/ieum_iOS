import UIKit
import SnapKit
import Then

final class DailyInputView: UIView {
    
    // MARK: - Properties
    
    var onTitleChanged: ((String) -> Void)?
    var onContentChanged: ((String) -> Void)?
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Slate.s200.cgColor
    }
    
    private lazy var titleTextField = UITextField().then {
        $0.placeholder = "제목을 입력해 주세요"
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
        $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = Colors.Slate.s200
    }
    
    private lazy var contentTextView = UITextView().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.textContainerInset = .zero
        $0.textContainer.lineFragmentPadding = 0
    }
    
    private let placeholderLabel = UILabel().then {
        $0.text = "자유롭게 이야기를 기록해 보세요."
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g400
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleTextField)
        containerView.addSubview(dividerView)
        containerView.addSubview(contentTextView)
        containerView.addSubview(placeholderLabel)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.leading.equalTo(contentTextView)
        }
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        onTitleChanged?(textField.text ?? "")
    }
}

// MARK: - UITextViewDelegate

extension DailyInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        onContentChanged?(textView.text)
    }
}

