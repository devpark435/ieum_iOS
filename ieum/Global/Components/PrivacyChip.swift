import UIKit
import SnapKit
import Then

class PrivacyChip: UIView {
    
    // MARK: - Properties
    
    var onCheckChanged: ((Bool) -> Void)?
    
    var isChecked: Bool = false {
        didSet {
            updateCheckBoxState()
            onCheckChanged?(isChecked)
        }
    }
    
    // MARK: - UI Components
    
    private let checkBoxButton = UIButton().then {
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.Slate.s300.cgColor
        $0.backgroundColor = Colors.white
        $0.setImage(nil, for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "비공개"
        $0.font = .ieum(UIFont.IeumFont.label)
        $0.textColor = Colors.Gray.g950
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
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = Colors.Gray.g200.cgColor
        
        addSubview(checkBoxButton)
        addSubview(titleLabel)
    }
    
    private func setupLayout() {
        checkBoxButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkBoxButton.snp.trailing).offset(8)
            $0.centerY.equalTo(checkBoxButton)
            $0.trailing.equalToSuperview().inset(12)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(40)
        }
    }
    
    private func setupActions() {
        checkBoxButton.addTarget(self, action: #selector(didTapCheckBox), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCheckBox))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func didTapCheckBox() {
        isChecked.toggle()
    }
    
    private func updateCheckBoxState() {
        if isChecked {
            checkBoxButton.backgroundColor = Colors.Emerald.e600
            checkBoxButton.layer.borderWidth = 0
            
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
            let checkImage = UIImage(systemName: "checkmark", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            checkBoxButton.setImage(checkImage, for: .normal)
        } else {
            checkBoxButton.backgroundColor = Colors.white
            checkBoxButton.layer.borderWidth = 1
            checkBoxButton.layer.borderColor = Colors.Slate.s300.cgColor
            checkBoxButton.setImage(nil, for: .normal)
        }
    }
}
