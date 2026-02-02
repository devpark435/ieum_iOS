import UIKit
import SnapKit
import Then

class InProgressChip: UIView {
    
    // MARK: - Properties
    
    var onCheckChanged: ((Bool) -> Void)?
    
    var isChecked: Bool = false {
        didSet {
            guard oldValue != isChecked else { return }
            checkbox.isChecked = isChecked
            updateStyle()
            onCheckChanged?(isChecked)
        }
    }
    
    // MARK: - UI Components
    
    private let checkbox = IeumCheckbox()
    
    private let titleLabel = UILabel().then {
        $0.text = "진행중이에요"
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
        layer.cornerRadius = 12
        addSubview(checkbox)
        addSubview(titleLabel)
        updateStyle()
    }
    
    private func setupLayout() {
        checkbox.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkbox.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        
        snp.makeConstraints {
            $0.height.equalTo(32)
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapChip))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        
        checkbox.onCheckChanged = { [weak self] isChecked in
            guard let self = self, self.isChecked != isChecked else { return }
            self.isChecked = isChecked
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapChip() {
        isChecked.toggle()
    }
    
    private func updateStyle() {
        if isChecked {
            backgroundColor = Colors.Gray.g950
            titleLabel.textColor = Colors.white
            layer.borderWidth = 0
        } else {
            backgroundColor = Colors.white
            titleLabel.textColor = Colors.Gray.g950
            layer.borderWidth = 1
            layer.borderColor = Colors.Gray.g200.cgColor
        }
    }
}
