import UIKit
import SnapKit
import Then

final class MealInputViewController: DimmedViewController {
    
    // MARK: - Properties
    
    var onComplete: ((MealStatus, String?) -> Void)?
    
    private var selectedStatus: MealStatus = .good {
        didSet {
            updateChipSelection()
        }
    }
    
    private var containerBottomConstraint: Constraint?
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "어떻게 드셨나요?"
        $0.font = .ieum(UIFont.IeumFont.Heading.h4)
        $0.textColor = Colors.Gray.g950
    }
    
    // Chips
    private let chipsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    private lazy var goodChip = createChip(title: "잘먹음", icon: "face-smile", status: .good)
    private lazy var littleChip = createChip(title: "소량", icon: "face-neutral", status: .little)
    private lazy var badChip = createChip(title: "못먹음", icon: "face-frown", status: .bad)
    
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
        $0.text = "식사 내용을 적어주세요"
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
    
    override init() {
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
        updateChipSelection()
        
        setupKeyboardObservers()
        
        doneButton.isEnabled = true
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
    
    private func createChip(title: String, icon: String, status: MealStatus) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(Colors.Gray.g600, for: .normal)
        button.titleLabel?.font = .ieum(UIFont.IeumFont.Text.bodySmall)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.Gray.g200.cgColor
        
        let image = UIImage(systemName: "face.smiling")
        button.setImage(image, for: .normal)
        button.tintColor = Colors.Gray.g600
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.selectedStatus = status
        }), for: UIControl.Event.touchUpInside)
        
        return button
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(chipsStackView)
        chipsStackView.addArrangedSubview(goodChip)
        chipsStackView.addArrangedSubview(littleChip)
        chipsStackView.addArrangedSubview(badChip)
        
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
        
        chipsStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(chipsStackView.snp.bottom).offset(20)
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
    
    private func updateChipSelection() {
        let chips: [(UIButton, MealStatus)] = [
            (goodChip, .good),
            (littleChip, .little),
            (badChip, .bad)
        ]
        
        for (btn, status) in chips {
            if status == selectedStatus {
                btn.backgroundColor = Colors.Lime.l100
                btn.layer.borderColor = Colors.Lime.l400.cgColor
                btn.setTitleColor(Colors.Lime.l500, for: .normal)
                btn.tintColor = Colors.Lime.l500
            } else {
                btn.backgroundColor = Colors.white
                btn.layer.borderColor = Colors.Gray.g200.cgColor
                btn.setTitleColor(Colors.Gray.g600, for: .normal)
                btn.tintColor = Colors.Gray.g600
            }
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
        onComplete?(selectedStatus, textView.text)
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

extension MealInputViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
