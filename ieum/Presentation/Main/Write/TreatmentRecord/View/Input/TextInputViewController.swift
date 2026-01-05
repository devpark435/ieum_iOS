import UIKit
import SnapKit
import Then

final class TextInputViewController: DimmedViewController {
    
    // MARK: - Properties
    
    var onComplete: ((String) -> Void)?
    
    private let titleText: String
    private let placeholderText: String
    private var containerBottomConstraint: Constraint?
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Heading.h4)
        $0.textColor = Colors.Gray.g950
    }
    
    private lazy var textView = UITextView().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g950
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Gray.g200.cgColor
        $0.delegate = self
    }
    
    private let placeholderLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Text.bodyM)
        $0.textColor = Colors.Gray.g400
        $0.numberOfLines = 0
    }
    
    private let doneButton = IeumButton(title: "완료", radius: 0).then {
        $0.titleLabel?.font = .ieum(UIFont.IeumFont.Btn.large)
        $0.setStyle(backgroundColor: Colors.Treatment.buttonBackground, titleColor: Colors.white, for: .normal)
        $0.setStyle(backgroundColor: Colors.Gray.g200, titleColor: Colors.Gray.g400, for: .disabled)
    }
    
    // MARK: - Initializer
    
    init(title: String, placeholder: String) {
        self.titleText = title
        self.placeholderText = placeholder
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
        
        titleLabel.text = titleText
        placeholderLabel.text = placeholderText
        
        setupKeyboardObservers()
        
        doneButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textView)
        textView.addSubview(placeholderLabel)
        containerView.addSubview(doneButton)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            self.containerBottomConstraint = $0.bottom.equalToSuperview().constraint
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(160)
            $0.bottom.equalTo(doneButton.snp.top).offset(-24)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        doneButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(72)
        }
    }
    
    private func setupActions() {
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tap)
        
        let containerTap = UITapGestureRecognizer(target: self, action: nil)
        containerView.addGestureRecognizer(containerTap)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @objc private func didTapDone() {
        onComplete?(textView.text)
        textView.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @objc private func didTapBackground() {
        textView.resignFirstResponder()
        dismiss(animated: true)
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        containerBottomConstraint?.update(offset: -keyboardHeight)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        containerBottomConstraint?.update(offset: 0)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

extension TextInputViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        placeholderLabel.isHidden = !text.isEmpty
        doneButton.isEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
