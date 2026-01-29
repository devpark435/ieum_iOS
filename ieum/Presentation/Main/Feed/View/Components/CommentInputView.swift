import UIKit
import SnapKit
import Then

final class CommentInputView: UIView {
    
    // MARK: - Properties
    
    var onSendTapped: ((String) -> Void)?
    
    // MARK: - UI Components
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = Colors.Gray.g200
        $0.layer.cornerRadius = 20 // Height 40 / 2
        $0.clipsToBounds = true
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Gray.g950.cgColor
        $0.layer.cornerRadius = 16
    }
    
    private lazy var textView = UITextView().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.delegate = self
        $0.textContainerInset = .zero
        $0.textContainer.lineFragmentPadding = 0
    }
    
    private let placeholderLabel = UILabel().then {
        $0.text = "댓글을 남김"
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g400
    }
    
    private let sendButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "arrow.up", withConfiguration: config)
        $0.setImage(image, for: .normal)
        
        // 아이콘 색상 설정
        $0.tintColor = Colors.black
        
        $0.backgroundColor = Colors.Lime.l400
        $0.layer.cornerRadius = 16
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = Colors.white
        
        addSubview(profileImageView)
        addSubview(containerView)
        addSubview(sendButton)
        
        containerView.addSubview(textView)
        containerView.addSubview(placeholderLabel)
    }
    
    private func setupLayout() {
        // Margins: 24pt
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().offset(-24)
            $0.width.height.equalTo(40)
        }
        
        sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-24)
            $0.width.equalTo(70)
            $0.height.equalTo(40)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-24)
            $0.trailing.equalToSuperview().inset(24) // Initial state (Button hidden)
            $0.height.greaterThanOrEqualTo(40)
        }
        
        
        textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.height.equalTo(20).priority(.high)
            $0.height.lessThanOrEqualTo(100)
        }
        
        
        placeholderLabel.snp.makeConstraints {
            $0.leading.equalTo(textView)
            $0.centerY.equalTo(textView)
        }
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapSend() {
        guard let text = textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        onSendTapped?(text)
        textView.text = ""
        textViewDidChange(textView)
    }
    
    func focus() {
        textView.becomeFirstResponder()
    }
    
    func resign() {
        textView.resignFirstResponder()
    }
    
    func clearText() {
        textView.text = ""
        textViewDidChange(textView)
    }
}

// MARK: - UITextViewDelegate

extension CommentInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        let hasText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        placeholderLabel.isHidden = !text.isEmpty
        sendButton.isHidden = !hasText
        
        if hasText {
            // Button Visible: Container trails to Button
            containerView.snp.remakeConstraints {
                $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
                $0.top.equalToSuperview().offset(8)
                $0.bottom.equalToSuperview().offset(-24)
                $0.trailing.equalTo(sendButton.snp.leading).offset(-12)
                $0.height.greaterThanOrEqualTo(40)
            }
        } else {
            // Button Hidden: Container trails to Superview
            containerView.snp.remakeConstraints {
                $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
                $0.top.equalToSuperview().offset(8)
                $0.bottom.equalToSuperview().offset(-24)
                $0.trailing.equalToSuperview().inset(24)
                $0.height.greaterThanOrEqualTo(40)
            }
        }
    }
}
