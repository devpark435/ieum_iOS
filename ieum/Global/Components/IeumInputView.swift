import UIKit
import SnapKit
import Then

class IeumInputView: UIView {
    
    // MARK: - Types
    
    enum InputType {
        case `default`
        case search
        case dropdown
    }
    
    // MARK: - Properties
    
    private let type: InputType
    private let maxCharacterCount: Int?
    
    // Border Colors
    var defaultBorderColor: UIColor = Colors.transparent
    var activeBorderColor: UIColor = Colors.Primary.green
    
    // Actions
    /// 우측 아이콘(검색, 드롭다운) 탭 시 실행될 클로저
    var onIconTap: (() -> Void)?
    
    /// 드롭다운 타입일 때 뷰 전체 탭 시 실행될 클로저
    var onDropdownTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 6
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.white
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = Colors.transparent.cgColor
    }
    
    let textField = UITextField().then {
        $0.font = .ieum(UIFont.IeumFont.Input.placeholder)
        $0.textColor = Colors.Gray.g950
        $0.borderStyle = .none
    }
    
    private let rightIconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Colors.Gray.g950
        $0.isHidden = true
        $0.isUserInteractionEnabled = true // 탭 가능하도록 설정
    }
    
    private let countLabel = UILabel().then {
        $0.font = .ieum(UIFont.IeumFont.Helper.characterCount)
        $0.textColor = Colors.Gray.g400
        $0.textAlignment = .right
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    
    init(type: InputType = .default, placeholder: String? = nil, maxCount: Int? = nil) {
        self.type = type
        self.maxCharacterCount = maxCount
        super.init(frame: .zero)
        
        setupUI()
        setupLayout()
        setupType()
        setupActions()
        
        textField.placeholder = placeholder
        containerView.layer.borderColor = defaultBorderColor.cgColor
        
        // 제스처 추가
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(containerView)
        
        containerView.addSubview(textField)
        containerView.addSubview(rightIconImageView)
        
        if let maxCount = maxCharacterCount {
            stackView.addArrangedSubview(countLabel)
            countLabel.text = "0/\(maxCount)"
            countLabel.isHidden = false
        }
    }
    
    private func setupLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        
        let rightPadding = (type == .default && maxCharacterCount == nil) ? 16 : 40
        
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(rightPadding)
        }
        
        if type != .default {
            rightIconImageView.snp.makeConstraints {
                $0.width.height.equalTo(24)
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(16)
            }
        }
    }
    
    private func setupType() {
        switch type {
        case .default:
            rightIconImageView.isHidden = true
            textField.isUserInteractionEnabled = true
        case .search:
            rightIconImageView.image = Images.Icon.search
            rightIconImageView.isHidden = false
            textField.isUserInteractionEnabled = true
        case .dropdown:
            rightIconImageView.image = Images.Icon.dropdown
            rightIconImageView.isHidden = false
            textField.isUserInteractionEnabled = false // 드롭다운은 입력 불가
        }
    }
    
    private func setupActions() {
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        
        if maxCharacterCount != nil {
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    private func setupGestures() {
        // 아이콘 탭 제스처
        let iconTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapIcon))
        rightIconImageView.addGestureRecognizer(iconTapGesture)
        
        // 드롭다운인 경우 컨테이너 전체 탭 제스처
        if type == .dropdown {
            let containerTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDropdown))
            containerView.addGestureRecognizer(containerTapGesture)
        }
    }
    
    // MARK: - Configuration Methods
    
    func setBorderColors(defaultColor: UIColor, activeColor: UIColor) {
        self.defaultBorderColor = defaultColor
        self.activeBorderColor = activeColor
        
        if !textField.isEditing {
            containerView.layer.borderColor = defaultColor.cgColor
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapIcon() {
        onIconTap?()
    }
    
    @objc private func didTapDropdown() {
        onDropdownTap?()
    }
    
    @objc private func textFieldDidBeginEditing() {
        containerView.layer.borderColor = activeBorderColor.cgColor
    }
    
    @objc private func textFieldDidEndEditing() {
        containerView.layer.borderColor = defaultBorderColor.cgColor
    }
    
    @objc private func textFieldDidChange() {
        guard let maxCount = maxCharacterCount, let text = textField.text else { return }
        countLabel.text = "\(text.count)/\(maxCount)"
        countLabel.textColor = text.count > maxCount ? Colors.Red.r500 : Colors.Gray.g400
    }
}
