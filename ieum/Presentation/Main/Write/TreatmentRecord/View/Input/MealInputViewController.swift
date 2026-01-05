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
        $0.font = .ieum(UIFont.IeumFont.Heading.h2) // h4 -> h2
        $0.textColor = Colors.Gray.g950
    }
    
    // Chips
    private let chipsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12 // 버튼 사이 여백 12
        $0.distribution = .fillEqually
    }
    
    private lazy var goodChip = createChip(title: "잘먹음", icon: "meal-good", status: .good)
    private lazy var littleChip = createChip(title: "소량", icon: "meal-small", status: .little)
    private lazy var badChip = createChip(title: "못먹음", icon: "meal-poor", status: .bad)
    
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
        
        button.backgroundColor = Colors.white
        button.layer.cornerRadius = 16 // radius 16
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.Slate.s200.cgColor // 기본 Border
        
        // Custom Content Layout
        // 좌우 10 상하 14 여백, 아이콘-텍스트 4 간격
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        
        let iconView = UIImageView(image: UIImage(named: icon))
        iconView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = title
        label.font = .ieum(UIFont.IeumFont.Text.bodySmall) // 폰트 사이즈 확인 필요 (bodyM or bodySmall? 버튼이므로 bodyM?) -> bodySmall로 일단 설정
        label.textColor = Colors.Gray.g600
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        
        button.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(14)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.center.equalToSuperview()
        }
        
        iconView.snp.makeConstraints {
            $0.width.height.equalTo(24) // 아이콘 크기 적절히 조절
        }
        
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.selectedStatus = status
        }), for: UIControl.Event.touchUpInside)
        
        // Tag to identify labels/icons later if needed, or updateChipSelection updates styles directly
        button.tag = status.hashValue 
        
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
            // Height determined by content padding
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
            // Find label inside stack
            guard let stack = btn.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
                  let label = stack.arrangedSubviews.compactMap({ $0 as? UILabel }).first else { continue }
            
            if status == selectedStatus {
                // 선택됨: Border Green 500, Text/Icon Color Green 500? or Gray 950?
                // 요청: "선택한애가 볼더색이 바껴야해 00C950 그린 500"
                // 텍스트 색상에 대한 언급은 없으나 보통 선택 시 강조됨.
                // 기존 로직: Lime 계열이었음. -> Green 500 Border.
                // 배경색 언급 없음 -> 흰색 유지 or 연한 그린? "선택한애가 볼더색이 바껴야해"만 언급됨.
                // 배경은 흰색, Border Green 500, 텍스트/아이콘 색상은 변경 여부 불확실 -> 보통 Primary Color로 변경.
                
                btn.backgroundColor = Colors.white
                btn.layer.borderColor = Colors.Green.g500.cgColor
                label.textColor = Colors.Green.g500
                // Icon tint? Images might be colored assets. If template, tint. If not, keep original.
                // Assuming template or tintable for now since user mentioned "new assets".
                // If assets are colored images, tintColor won't affect them unless rendering mode is template.
                // Let's assume we should tint or keep as is.
            } else {
                btn.backgroundColor = Colors.white
                btn.layer.borderColor = Colors.Slate.s200.cgColor
                label.textColor = Colors.Gray.g600
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
