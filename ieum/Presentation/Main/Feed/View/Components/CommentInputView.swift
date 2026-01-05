import UIKit
import SnapKit
import Then

final class CommentInputView: UIView {
    
    // MARK: - Properties
    
    var onSendTapped: ((String) -> Void)?
    
    // MARK: - UI Components
    
    private let profileImageView = UIImageView().then {
        $0.backgroundColor = Colors.Gray.g200
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Gray.g200.cgColor
        $0.layer.cornerRadius = 20
    }
    
    private lazy var textView = UITextView().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false // Auto-expand
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
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let image = UIImage(systemName: "arrow.up", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.backgroundColor = Colors.Lime.l400
        $0.tintColor = Colors.white
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
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-12)
            $0.width.height.equalTo(32)
        }
        
        sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-12)
            $0.width.height.equalTo(32)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            // Initial trailing: if button hidden, anchor to superview trailing? 
            // Or always reserve space? 
            // "입력전까지는 전송버튼이 안나오는거고" -> If not shown, maybe Input expands?
            // Let's assume input expands.
            $0.trailing.equalToSuperview().inset(20) 
        }
        
        textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.height.greaterThanOrEqualTo(20)
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
                $0.bottom.equalToSuperview().offset(-8)
                $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
            }
        } else {
            // Button Hidden: Container trails to Superview
            containerView.snp.remakeConstraints {
                $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
                $0.top.equalToSuperview().offset(8)
                $0.bottom.equalToSuperview().offset(-8)
                $0.trailing.equalToSuperview().inset(20)
            }
        }
    }
}
